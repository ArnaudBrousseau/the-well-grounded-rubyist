# The Well-Grounded Rubyist
I'm reading this, and keeping track of the things I'm learning along the way.

## `load` vs `require`

* `load` is for files, and does not keep track of whether files are loaded or
  not. Useful for re`load`ing in interactive IRB sessions
* `require` is for "features". File extensions don't matter and the underlying
  feature can be in C or Ruby. Requiring a file twice will result in a single
  inclusion (good for performance)

## Gems

To install from local

    $ gem install /path/to/gem

To install a gem AND ALL ITS DEPS from local:

    $ gem install -l /path/to/gem

Same, but only remote:

    $ gem install -r bundler

## Misc Tips

Syntax check:

    $ ruby -wc program.rb

Executing inline ruby code

    $ ruby -e 'puts 4+7'

Echoing Ruby's load path

    $ ruby -e '$:'

Requiring stuff into `irb` and `ruby`

    $ irb -r rbconfig
    $ ruby -r rbconfig -e 'RbConfig::CONFIG["sitedir"]'

Grep in Ruby!

    $ ruby -e 'puts $:.grep(/arnaud/)'

Using a different version of a Gem in irb:

    $ irb
    >> gem "bundler", "1.17.3"

Rounding floats:

    $ irb
    >> num = 10.1234
    >> puts "#{num} rounded is #{"%.2f" % num}"
    10.12


## Objects

Attaching methods to objects is a fundamental capability in Ruby:

```ruby
obj = Object.new
def obj.double(num)
  return num*2
end
obj.double(4)  # returns 8

```

* `obj.foo` is an expression to send the message `foo` to the object `obj`
* Equivalent statement: method `foo` is called on object `obj`
* "formal parameters" are the variables listed in the method definition
* "arguments" are the values supplied by callers

In Ruby: `foo.bar` is the same as `foo.send('bar')` (or `foo.__send__('bar')`)

Using parenthesis in Ruby? Yes! **When in doubt, use parens**. Exceptions:
* Empty params or args
* Call to `puts`

To list object methods:

    >> puts obj.methods.sort

Arguments:
* `(*a)` accepts 0 or more args, `(a, b, *c)` accepts 2 or more. `a` and `c`, respectively, will be arrays.
* `(a, *b, c)` is possible. `(1, 2, 3, 4)` results in `a=1`, `b=[2,3]` and `c=4`. Pretty neat.
* When default values are in the mix `(a=1, *b, c)`, they win over the generic arg. A call with `(11, 22)` will result in `a=11`, `b=[]`, `c=22`.
* What can't be done: `(x, *y, z=1)` or `(*x, *y)`

In Ruby, almost every variable hold a reference to their values (even string vars!). Exceptions are variable holding "immediate values". They are:
* symbols
* numbers
* `true`, `false`, `nil`

To workaround the fact that everything is passed by reference: `.clone`/`.dup`
gives a fresh copy of the object, and `.freeze` prevents any further
modification to it. Note: `.clone` keeps frozen objects frozen. `.dup` doesn't.

Warning `["one", "two", "three"].freeze` does not freeze the items (strings)
inside of the array!
```ruby
>> arr = ["one", "two", "three"].freeze
>> arr[0].replace("pwnd")
>> arr
=> ["pwnd", "two", "three"]
```

## Classes

It's possible to reopen classes:
```ruby
class C
  def x
  end
end

class C
  def y
  end
end
```

Constructors are called with `.new`, and declared with `def
initialize(...args...)`.

Syntactic sugar on top of setters:
```ruby
class Computer
  def brand=(brand)
    @brand = brand
  end
end

computer = Computer.new
computer.brand=('Apple')
computer.brand = 'Apple' # Equivalent!
```

Careful however, the syntactic sugar version returns whatever is on the
right-hand side instead of what the setter method returns.

Other shortcut: `attr_*` methods:
```ruby
class Computer
  attr_writer :brand
  attr_reader :owner
  attr_accessor :price
end
```

`Object` is the base class of all Ruby objects. It has 58 methods implemented.
`BasicObject`, on the other hand, only has 8. `BasicObject` is very rarely used
however.

In Ruby classes are objects as well:
```ruby
foo_class = Class.new do
  def double(num)
    num*2
  end
end

foo_instance = foo_class.new
foo_instance.double(2)  # >> 4
```

Paradox: `Class` and `Object` are both classes. They're also objects.
Chicken-and-egg problem? Ruby objects have a pointer to which class they're an
instance of, and `Class has a self-reference`.

Surprisingly enough: `Class.superclass` returns `Module` ("instance-less"
classes).

In Ruby, "class methods" are simply methods defined on a Class objects directly:
```ruby
class Foo
end

def Foo.classmethod
  puts "I am a class method"
end
```

Notation-wise:
* `Foo#bar` refers to the instance method bar
* `Foo.bar` or `Foo::bar` refers to the class method bar

Constants in Ruby: they always start with a capital letter. If they're within a
class, they can be referred to by name. If they need to be referred to from
outside: `Foo::Constant` is the way to refer to them.

Constants reassignment is discouraged through a warning, but modifying the
underlying values contained in a constant doesn't produce a warning (need
`freeze` to trutly freeze values!)

## Modules

Modules and classes are similar. They're both groups of functionality. Classes
have instances, modules do not. A class can only inherit from one parent, but
can include more than one module.

Shortcut methods:
* `foo &&= bar` (similar to `||=`): expands to `foo = foo && bar`

Modules should be **adjectives**. Classes **nouns**. That's because modules
define behaviors and classes model entities.

The base `Object` class mixes in the `Kernel` module. That's where most of
Ruby's base methods are implemented (`respond_to`, `equal?`, etc). In other
words:

```
>> class UserClass end
>> UserClass.ancestors
=> [UserClass, Object, Kernel, BasicObject]
```

Search path for method: class, mixed-in method, superclass, mixed-in method,
etc...until `BasicObject` is reached.

Paradox: `BasicObject` is an `Object`, `Object` is a `Class` and `Class` is an
`Object`. Wow.

`prepend MyModule` in a class does the same than `include MyModule`, except the
module's methods take precedence over the class'.

`extend MyModule` makes `MyModule`'s methods available as **class** methods
(whereas `include` or `prepend` make methods available as instance methods)

To call the next method in the call chain: `super` or `super(args)` (`super`
with no args automatically forward call args)

`myclass.method(:foo).super_method` returns `nil` or the next `foo` method in
the call chain.

A common pattern for program structure is to nest classes inside of modules for
namespacing:
```ruby
module Tools
  class Hammer
  end
  class Nail
  end
end

>> Tools::Hammer.new
=> #<Tools::Hammer:0x00007ffca916e178>
```

## Scope and visibility

Ruby has `self`, which is similar to JavaScript's `this`. The value varies depending on context:
* at the top level, `self` is `main` (the buit-in top-level default object)
* in a class, module, class method or instance method definition, `self` represents the class object, module object, class object or instance respectively

Alternative syntax for class methods:
```
class C
  class << self
    def x
    end
    def y
    end
  end
end
```

In Ruby, `self.method` can me shortened to `method`. **`self`** is the default
receiver of messages.

Class and instance object can both have "instance" variables:
```ruby
class Foo
  attr_reader :bar
  @bar = 42
  def set_bar
    @bar = 44
  end
end

foo = Foo.new
foo.bar
=> nil
foo.set_bar
foo.bar
=> 44
```

Globals:
* they start with `$`
* `$0` is the program filename, `$$` is the PID. If `require 'English'` is
  inserted, more user-friendly names are assigned (`$PROGRAM_NAME`, `$PID`)

A new scope is created for each `module`, `class` or `def` context. This resets local and constant vars:

```ruby
class O
  x = 1
  X = -1
  class H
    x = 2
    X = -2
    module M
      x = 3
      X = -3
      module Y
        x = 4
        X = -4
        def log
          puts 'gad'
        end
        puts "{x} {X}"
      end
      puts "{x} {X}"
    end
    puts "{x} {X}"
  end
  puts "{x} {X}"
end
```

Constants can be referred to with a relative path (`H::M::Y::X`) or absolute
(`::O::H::Y::X`). `::` is equivalent to `/` for linux paths.

Class variables are shared by a class and all of its instances AND all
subclasses and all of their instances too. They're **class-hierarchy-scoped**.

```ruby
class P
  @@val = 100
end
class C < P
  @@val = 200
end
class P
  puts @@val // prints 200
end
```

Generally speaking it's best to avoid class variables and use instance variable
of class objects (single `@`) such that these variables aren't shared with
subclasses.

Private methods can be declared:
* with the function `private` on its own (all methods declared below will be
  `private` unless `public` or `protected is called)
* with the function `private` applied to specific functions (`private
  :mymethod`) -- I personally prefer this pattern better since it's more
  explicit which methods are made private.

Quirk: private setters have to be called with exactly `self`.
`self.private_setter = val` works, but `foo = self; foo.private_setter = val`
doesn't!

`protected` methods are only visible by other instances of the same class, or
instances part of the class hierarchy.

Interesting piece of trivia: defining a top-level method is like defining a
private method on the `Object` class!

`puts` and `print` are actually private methods of the `Kernel` module:

```
$ ruby -e 'p Kernel.private_instance_methods.sort'
[:Array, :Complex, :Float, :Hash, :Integer, :Rational, :String, :URI, :__callee__, :__dir__, :__method__, :`, :abort, :at_exit, :autoload, :autoload?, :binding, :block_given?, :caller, :caller_locations, :catch, :eval, :exec, :exit, :exit!, :fail, :fork, :format, :gem, :gem_original_require, :gets, :global_variables, :initialize_clone, :initialize_copy, :initialize_dup, :iterator?, :lambda, :load, :local_variables, :loop, :open, :p, :pp, :print, :printf, :proc, :putc, :puts, :raise, :rand, :readline, :readlines, :require, :require_relative, :respond_to_missing?, :select, :set_trace_func, :sleep, :spawn, :sprintf, :srand, :syscall, :system, :test, :throw, :trace_var, :trap, :untrace_var, :warn]
```

