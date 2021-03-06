# The Well-Grounded Rubyist
I'm reading [this
book](https://www.amazon.com/Well-Grounded-Rubyist-David-Black/dp/1617295213)
and keeping track of the things I'm learning along the way with this repo.

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

## Productivity Tips

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

Accessing the last computed value in IRB: possible with the special `_` variable:

    $ irb
    >> 1+1
    => 2
    >> result = _
    => 2


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

## Arguments
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

Ruby has real keyword arguments (!!):
```
def sum(a:, b:2)
  a + b
end

sum(a: 1)
=> 3

sum(a: 1, b: 5)
=> 6
```

It's also possible to sponge up extra kwargs with them
```
def foo(a:, b: 1, **kwargs)
  puts kwargs
end

foo(a: 1, c: 3, d: 4)
=> {c: 3, d: 4}
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

## Control flow

Interesting fact: local vars inside of conditionals get initialized to `nil` even when the condition is unsatisfied:
```ruby
if false
  x = 1
end
puts x  # outputs "nil"
puts y  # throws an error!
```

Case statements can take multiple values. Kinda neat:
```ruby
case x
when "1", 1, "one"
  # do once
when "2", 2, "two"
  # do twice
else
  # default
end
```
Interesting fact: `case`/`when` statements are syntactic sugar on top of the
`===` method. Classes can override `===` explicitly if they decide to. If no
explicit `===` is defined, `===` is interpreted as `==`.

Case statements do not have to be about a variable! It's then equivalent to a
standard `if`/`elsif`/.../`else` structure:
```ruby
case
when it_is_sunny
  # go to beach
when it_pours
  # stay inside & program
else
  # when it doubt play video games
end
```

Loops in Ruby:
* `loop { block }`
* `break` / `next`
* `while`
* `until`
* `for item in array; ....; end`

Loops in Ruby have concise syntax: `n = n + 1 until n > 10`

It's also possible to perform the first iteration before testing the condition by putting it after the `end` keyword:
```ruby
begin
  puts "hi"
end while false
# ==> will print "hi" once
```

Method calls in Ruby have arguments and optional blocks if they can `yield`.
The precedence is different between `do`/`end` syntax and `{...}`:
```ruby
puts [1,2,3].map { |n| n*10 }
# ==> Parses as puts([1,2,3].map { |n| n*10 })

puts [1,2,3].map do |n| n*10 end
# ==> Parses as puts([1,2,3].map) do |n| n*10 end
```
Hence the general recommendation that 1-line blocks are kept with curly braces,
and longer-than-one-line blocks are expressed with `do`/`end`.

`each`'s return value is the original receiver when called with a block, or an
`Enumerator` when called without. `map` returns a new set of items when called with a block, and also an `Enumerator` when called without one.

Block variable scoping rules:
* if there's no block variable name conflict, read-write access to outer
  variables is granted from
  within a block
* otherwise (say, outer `x`, and we do `.each { |x| ... }`) block variables
  "shadow" outer variables: outer vars will keep their value even upon
  assignment in the block (no overwrite)

It's possible to define **reserved names** for block variables!
```ruby
x = 100
6.times do |i;x|
   x = rand(0..100)
   puts "Iteration: ##{i}, x is: #{x}"
end
puts "x is still #{x}"
```
But really: changing the var name is probably a best practice to avoid confusion!

the method or block acts as an implicit `begin`.

Various tips relating to error handling:
* `rescue` blocks can be put at the end of methods or other blocks. The start of
* To insert a debugger: `require 'pry'; binding.pry` is cool. Better version: `binding.irb`!
* `&.` is the "safe navigation" operator. It only calls if the receiver is not
  `nil`. This is handy to traverse object trees.
* in Ruby, `ensure` is the equivalent of `finally` in other languages

## Built-in Essentials

Ruby lets users of the language use all of the "sugar" available to the core of the language:
* Arithmetic operations: `+`, `-`, `*`, `/`, `%` (modulo), `**` (exponent), `|`, `&`, `^`
* Get/set: `[]`, `[]=` (makes `x[y]`, `x[y] = z` "just work")
* Append (`<<`)
* Comparison: `==`, `===` (case equality), `<`, `>`, `<=`, `>=`
* Spaceship! `<=>` (returns -1 if a < b, 0 if a = b, 1 if a > b)

Holy crap you can even redefine unary operators! On built-ins! wat.
```ruby
class String
  def +@
    self.upcase
  end
end

+"hello"
=> "HELLO"
```
Unary operators: `+`, `-`, `!`

Convention in Ruby: method end in `!` if they're dangerous (mutate caller,
mutate receiver, skip some safety checks or cleanup, etc). Example: `reverse`
vs `reverse!`, `sort` vs `sort!`.

Important to consider overriding:
* `to_s` (used by `puts` and a lot of other use cases)
* `inspect` (output in irb)

`Struct`s are super useful:
```ruby
Transaction = Struct.new(:sender, :receiver, :amount, :fees)
Transaction.new("Arnaud", "Ryan", 100, 1)
```

`*` operator to "unarray" or "destructure":
```ruby
def add(a, b); a+b; end;
add(*[1, 2])
=> 3
```

Suprisingly enough, `'hello'.to_i` does not error out. It's just `0`. And
`'42wow'.to_i` is `42`. Wow. To get stricter behavior, `Integer` and `Float` are available:
```ruby
'nonsense'.to_i
=> 0
Integer('nonsense')
=> ArgumentError (invalid value for Integer(): "nonsense")
```

Concept of "role playing": defining `to_str` and `to_ary` is a way to make ruby
think your class can behave as an string or array. If these methods are defined
they'll be called automatically when operators like `+` or `<<` (which expects
a String) or `concat` (which expects an Array) are called on an object.

In Ruby, `true` and `false` are objects. They have boolean values of `True` and
`False` respectively. Every object in Ruby has a True boolean value except for
`nil` and `false`.

In Ruby, `equal?` is Object identity equality and isn't typically redefined.
But `==` and `.eql?` are. `String` redefines `==` and `.eql?` to compare values
for instance.

For integers, `==` does implicit type conversion. `.eql?` doesn't:
```Ruby
5 == 5.0  # true
5.eql? 5.0  # false
```

Pro-tip: including `Comparable` and defining the "spaceship" operator on a
class gives full comparator compatibility for that class.

## Strings, symbols and heredocs

To produce strings without worrying about escaping characters:
* `%q{...}` produces a single-quoted string
* `%Q{...}`/`%{}` produces a double-quoted string

To produce multi-line strings, use "heredoc"s:
```ruby
multi_line_str = <<EOM
this text
spans multiple
lines.
EOM
```

Bonus: "squiggly heredoc"s (`<<~EOM...EOM`) automatically strip leading
whitespace. So handy. `<<-EOM...EOM` removes the requirement that the closing
`EOM` is in a flush-left position.

If a single-quoted heredoc is needed: `<<'EOM'...EOM` is the way to go.

Kind of mind-bending: heredocs do not have to be the only thing in their line:
```ruby
>> array = ["foo", <<EOM, "baz"]
bar
EOM
=> ["foo", "bar\n", "baz"]
```

String operations: `[]` support indexes, ranges, regex. Damn!

`string.count` method is very versatile (char ranges, multiple args, regexes):
`"abcdefghijklm".count("ag-m", "^l")` returns 7.

Other handy string methods for left/right padding, stripping, even centering:
`'hi'.center(20, '*')`

Funny names: `chop` (removes last character), `chomp` (removes newline, or any
specified substring if at the end)

Tip: `to_i` optionally takes a base as argument: `"110".to_i(2)` (returns 6).
`oct` and `hex` are also available (they're aliases for `to_i(8)` and `to_i(6)`
respectively.

About symbols:
* `'some string'.to_sym` is the same than `'some string'.intern`
* symbols are more like integers than strings. They're immutable. The same
  symbol share the same object ID
* variable names, method names, class names are symbols internally
* `Symbol.all_symbols` return all symbols. It's grep-able: `Symbol.all_symbols.grep(/foo/)`

Number gotchas:
* numbers leading with zeros are intepreted as octal based: `012 == 10`. wat.

Pro-tip: `ri` (CLI) (e.g. `$ ri DateTime`). That's the Ruby equivalent of `man`.

## Arrays

Arrays can be initialized with code blocks:
```ruby
Array.new(5) { |i| i*i }
# => [0, 1, 4, 9, 16]
```

In Ruby, `Array(obj)` calls `obj.to_ary` or `obj.to_a` if available. It's
rarely used. Some common ways to create arrays in Ruby:
* `%w[one two three]`
* `%W[one #{1 + 1} #{1 + 1 + 1}]
* `%i[one two]`, %I[one #{1 +1}]

`try_convert` is the general mechanism through which `Array`, `Hash`, `IO` or
`Regexp` work. `try_convert` relies on `to_ary`, `to_hash`, `to_io` and
`to_regexp` (resp.).

Fun-fact: in Ruby, `a[0] = 1` is sugar for `a.[]=(0, 1)`, and `a[0]` is sugar
for `a.[](0)`.

Range access: `a[2,4]`, `a[2..4]` (contiguous values) or `a.values_at(2,4)`
(non-contiguous values).

Other useful array methods:
* `dig` (to access nested indices)
* `unshift` (to prepend items), `shift` (pop from left)
* `push`/`<<` (append), `pop` (standard pop)
* `.flatten()`
* `.uniq()`
* `arr * '-'` is equivalent to `arr.join('-')`
* `compact` (removes `nil`s)
* `.sample(2)` (takes 2 sample elements from an array)

## Hashes

* `Hash.new(2)` creates a hash with a default value (for missing keys) of `2`
* `Hash["foo", 1, "bar", 2]` creates a hash with 2 elements. So does `Hash[["foo", 1], ["bar", 2]]`
* `dig` (to get deep keys), `compact` (removes nil values), and `values_at` also works for hashes!
* `fetch`/`store` are getter/setters, equivalent to `[]` and `[]=`. They accept blocks to transform the keys (

Recreating Python's `defaultdict`:
```ruby
# Values are initialized to 0 the first time they're accessed
defaultdict = Hash.new { |hash, key| hash[key] = 0 }
```

Hashes support `select` and `reject` to filter them arbitrarily.

Hashes are great way to emulate Python kwargs:
```ruby
def foo(a, b, info)
  puts a + b
  puts info.keys
end

foo(1, 2, three: 3, four: 4)
=> 3
=> [three, four]
```

Better though: real named keyword args, with defaults! (see "Arguments" above)

## Ranges
* can be inclusive (`1..100`, aka `[1, 100]`) or exclusive (`1...100`, aka `[1, 100[`)
* `begin`, `end` and `exclude_end?` are convenient to check bounds
* `include?` and `cover?` for membership test (e.g. `(1...100).cover?(50)`)

## Sets
* not built-in, needs `require 'set'`
* `Set.new(array)` is canonical
* `Set.add?` adds to the set and returns `nil` if the key was already present. Handy
* sets support the usual union/intersection/difference/xor through `+`/`&`/`-`/`^`
* support for `subset?`/`superset?` which is neat

## The magic of `Enumerable`s
Including `Enumerable` and defining `each` lets a class enjoy methods defined
in this method, defined in terms of `each`: `find`, `any?`, `select`, `reject`, etc.

Other neat `Enumerable` methods:
* `grep` (selects based on `===`, takes in a block
* `group_by` (splits a collection into a hash)
* `partition` (splits a collection in two arrays)
* `min`/`max`/`minmax` (and `min_by`, `max_by`, `minmax_by`)
* `each_with_index` (Python's `enumerate`): deprecated in favor of
  `each.with_index` (more idiomatic). Tip: `with_index(4)` enumerates indices
  starting from 4. Handy to handle collections starting with 1 vs 0 when
  enumerating arrays.
* `each_cons`: handy for windowing algorithms (`[1, 2, 3].each_cons(2)` results in `[1, 2], [2, 3]`)
* `slice_when { |i,j| ... }` is also super handy for iterating over an array efficiently
* `inject` to perform reductions. Example: `somme = -> (a) { a.inject(0) {
  |acc, n| acc + n } }; somme.call([2,2])`. Pro-level: `[2,3,4,5].inject(:+)`
  also works.
* The queen of all iteration methods, `map`. Ruby enable symbol blocks such as
  `name.map(&:upcase)` (remember `bar(&quux)` is the generic syntax to pass
  `quux` as a block argument to `bar`)

String enumerations: `each_byte`, `each_char`, `each_codepoint`, `each_line`.
To get arrays directly `bytes`, `chars`, `codepoints`, `lines`.
Niche feature: the value of `$/` ("global input record separator) drives what
Ruby thinks of as a line. It defaults to `\n`, but can be changed:
```ruby
>> $/ = '.'
>> 'what.is.going.on?'.each_line { |l| p l }
'what.'
'is.'
'going.'
'on?'
```
I don't really see a reason to do this, ever. But it's kinda quirky and cute.

## Sorting
In order for a collection to become sortable (`.sort`), the class of its items
has to implement the "spaceship" operator, to define ordering. Sort order is
also overridable on the fly, with a block:
```
>> [67, 48, 4, 38].sort
=> [4, 38, 48, 67]
>> [67, 48, 4, 38].sort { |a,b| b<=>a }
=> [67, 48, 38, 4]
```

`sort_by` is neat to sort collections of hashes: `[{foo: 2}, {foo: -1}, {foo:
3}].sort_by { |i| i[:foo] }` or `[{foo: 2}, {foo: -1}, {foo:
3}].sort_by(&:values)`.

## Enumerators
Enumerators are object which produce values through a yielder:
```ruby
e = Enumerator.new do |y|
  y << 1
  y << 2
  y << 42
end

>> e.each { |i| p i }
1
2
42

`some_obj.enum_for(method, arg1, arg2,...argN)` creates an Enumerator from an
object's method, such that it yields its values through one of its methods.
Default is, of course, `each`. But we can do:

```ruby
>> e = ['foo', 'bar', 'baz'].enum_for(:each_cons, 2)
=> #<Enumerator: ["foo", "bar", "baz"]:each_cons(2)>
>> e.to_a
=> [["foo", "bar"], ["bar", "baz"]]
```

Called without block args, most iteration methods return Enumerators (`each`, `each_byte`, `reverse_each`, etc)

Enumerators are a neat way to proxy access to a collection, such that the
collection is protected and guaranteed read-only: `[1,2,3].pop` works; `[1,2,3].enum_for.pop` doesn't.

Enumerators have state! `[1,2,3].each.next.next` & `[1,2,3].next.next.rewind` work as you would expect.

Lazy enumerators:
* `(1..Float::INFINITY).select { |n| n % 3 == 0 }.first(10)` => hangs forever
* `(1..Float::INFINITY).lazy.select { |n| n % 3 == 0 }.first(10)` => no problem

## Regexes
* defined with `/.../` or `%r{...}`
* to find out if there's a match: `str.match?(regex)`, `regex.match?(str)`, `str =~ regex`, `regex =~ str`, `regex === str` all work
* for complex regex, always use named capture groups: `(?<name>...)`, and retrieve with `named_captures[:name]`
* in addition to returning `MatchData` objects, Ruby populates the globals `$~`
  with the `MatchData` object or `nil`, and `$1`, `$2`, etc with each capture
  groups in the case of a match.
* To switch to non-greedy operators: add `?`. `'1234'.match(/\d+?/)[0]` returns
  `'1'`, whereas `'1234'.match(/\d+/)[0]` returns `'1234'`
* Ruby regex support is very complete, including: positive lookahead
  (`/(?=...)/`), negative lookahead (`/(?!...)/`), positive lookbehind
  (`/(?<=...)/`), negative lookbehind (`/(?<!.../`), ghost capture groups
  (`/(?:...)/`)
* Hail mary of regex: conditional matches: `/(a)?(?(1)b|c)/` matches ab, c, 5c. Don't ever use please?
* Trivia fact: Ruby's regex engine's name is "Onigmo"
* Modifiers: `i` (case insensitive), `m` (multiple lines), `x` (makes regex
  indifferent to whitespace, easier to structure/add comments to long regexes)

Methods using Regexes: `String#scan`, `Array#find_all`, `String#split`,
`String#sub`, `String#gsub` and `Enumerable#grep`.

## I/O, files, directories
I/O:
* `STDIN`, `STDOUT` and `STDERR` are constants
* `$stdin`/`$stdout`/`$stderr` are globals pointing to them. Globals can be
  reassigned to that raw `puts`/`gets`/errors go to non-standard IO streams

`File` objects:
* `read` (get everything), `readlines` (get all lines) -- also available as class methods
* `seek`, `rewind` (standard stuff)
* `gets` (get next line), `getc` (get next character), `getbyte` (get next byte)
* `readline`, `readchar`, `readbyte` (same than above, but do not error if end of file is reached)
* `puts`, `write` for writing to files
* `File.open(...) do |f| ... end` takes care of closing file descriptors
* `File` objects are enumerables and yield line-by-line (`File.new(...).each { |line| ... }`)
* `File` has a bunch of boolean methods to determine attributes: `empty?`,
  `exist?`, `readable?`, etc. This can also be done with `test ?e /tmp` (but
  that's arguably more obscure since it uses `Kernel#test` under the cover)
* `File` objects have a `stat` attribute with lots of info in it

`Dir` objects:
* `Dir.new(...).entries`
* `dir['*.txt']` or `dir.glob('*.txt')`

Neat module to perform file/directory operations: `FileUtils`. Has methods like
`cp`, `ln_s`, `rm_rf`, `mv`, etc. Also has dry-run and no-write options.

`Pathname` is a module to manipulate paths (get directory, extensions, concatenate paths together, go one level up/down)

`StringIO` is what you'd expect: a module to give strings a File-like interface
(makes it easier to test code which expects files)

## Singleton classes

Objects in Ruby have two classes:
* their standard class (`.class`)
* their *singleton* class (`.singleton_class`)

To add methods to an object's singleton class:
```ruby
def obj.foo
  puts 'first way'
end

class << obj
  def foo
    puts 'second way'
  end
end

module AddedMethod
  def foo
    puts 'third/fourth way'
  end
end
class Foo
  extend AddedMethod
end

class Foo
end
Foo.extend(AddedMethod)
```

`class << obj` should be read as "open up the single class of `obj`". Hence, when you see...
```ruby
class Foo
  class << self
    def foo
      puts 'I am a method'
    end
  end
end
```
...it should now be obvious that `class << self` opens up a block for
definitions of singleton methods of `self`, which is the class object Foo.

This block can also include or prepend modules:
```ruby
class Foo
  class << self
    include Enumerable
    def each
      yield 1
      yield 2
      yield 3
    end
  end
end
```

Gotcha: singleton classes of `Class` objects are inherited by children:
```
class Foo
  class << self
    def foo_method
      puts 'hi from foo'
    end
  end
end

class Bar < Foo
end

# totally works!
Bar.foo_method  # outputs 'hi from foo'
```

## The evil of modifying core classes
* Do not do it! It's never okay to redefine core methods
* Can be okay to add methods or optional args which do not break existing code
* `extend` is the safest way to override core methods (on a object-by-object basis)
* `refine` (which takes a block) and `using` (which uses the refinement in the
  current scope only) are the preferred way to scope core classes overrides

`BasicObject` can be useful to create classes which must behave in singular
ways, because `BasicObject` doesn't have much attached to it. No
`method_missing`, no `methods`, no `size`, etc.

A lot of the magic happens by implementing `method_missing`. The fewer methods
defined on the class, the more `method_missing` gets to intercept!

## Procs, Lambdas, and methods-as-object

`Proc`s are created with `Proc.new {...}` or `proc {...}

Procs can be passed as blocks with `obj.method(&a_proc)`, and blocks can be
turned into procs by defining `def method(a, b, &p)` (any block passed to
method will be turned into a proc and passed as an arg transparently).

The notation `&p` actually means `p.to_proc`. So,
`['hi','there'].map(&:capitalize)` is the same as `['hi','there'].map { |i|
:capitalize.to_proc.call(i) }`

Upon their creation procs create closures (callables are bundled with the
context they're created with).

What about lambdas? Well, they're procs too! So, what's different between a lambda and a proc?
* lambdas care about arity (number of args), and error out if you don't pass as many as they expect
* `return` from inside the lambda exits the lambda. Whereas `return` from inside a proc exits from whatever context the proc is called from.

Lambdas have a literal constructor: `square = -> (x) {x*x}`

Ruby lets you grab methods off of a class or object so that it can be passed
around with its context: `method = obj.method[:foo]`. By default, `method` is
bound to `obj`, but it's possible to call `unbind` and `bind` to re-bind to
another target. There's also `FooClass.instance_method[:foo]` which returns an
unbound method, directly.

Call mechanisms for a callable object (proc, lambda, detached method):
* `callable.call(arg1, arg2)`
* `callable[arg1, arg2]`
* `callable.(arg1, arg2)`

## Code evaluation
`eval(string_of_code, binding)` -- `binding` is a object, instance of
`Binding`, which encapsulates the current context. The function `binding`
returns the current context:
```ruby
def get_binding
  bar = 2
  b = binding()
  return b
end

# outputs "bar: 2"
eval('puts "bar: #{bar}"', get_binding())
```

Less evil than `eval`: `instance_eval`, with a block:
```ruby
class C
  def initialize
    @protected = 'secret'
  end
end
c = C.new
# prints "secret"
c.instance_eval { puts @protected }
```

There's also `class_eval` to evaluate a block or a string of code in the
context of class definition.

## Concurrency

Creating `Thread`s is easy:
```ruby
t = Thread.new do
 # code
end
t.join # wait until thread finishes
```
They work like you'd expect. They have threadlocal vars with `Thread#current`. They can be started (`join`, `run`), stopped (`kill`), etc.


Another concurrency construct in Ruby is `Fiber`s. They work like coroutines:
```ruby
f = Fiber.new do
  puts 'hello'
  Fiber.yield
  puts 'how'
  Fiber.yield
  puts 'are'
  Fiber.yield
  puts 'you'
  Fiber.yield
end
f.resume # hello
f.resume # how
f.resume # are
f.resume # you
```
Interesting fact: this is what Enumerators are built on under the hood.

To call to shell commands: `system('...')`, or `\`...\``, or `%x{...}`. `exec`
replaces the program with a shell (not so good!), and `open`/`popen3` are
low-level library used to do complex file descriptor manipulations.

## Runtime Inspection

* `obj.methods.sort` lists methods, sorted
* `obj.instance_methods` to list only instance methods
* `obj.instance_methods(false` lists only methods defined on a class (excluding
  ancestors
* `obj.singleton_methods` to list only methods on that particular object
* `private_methods`, `public_methods`, also works. Same for
  `private_instance_methods`, `public_instance_methods`. Works, but rarely
  used.

Ruby has a few runtime hooks available for metaprogramming (probably not useful unless you're writing a library!):
* `method_missing`, to dynamically respond to methods
* `respond_to_missing?`, such that `respond_to?` "sees" the metaprogrammed methods
* `self.const_missing` lets a class set defaults for constants and pretend they
  exist. Not sure it's such a good idea...
* `def self.included(cl)` (and `prepended`) lets a module run a callback
  whenever it's included into a class. This lets you do some tweaking to each
  class (defining instance methods, initializing some state, etc)
* `extended(obj)` also works, and gets called when an object extends a module
* `inherited` is a callback executed when a given class is subclassed. This
  does not work for singleton classes, only standard classes!
* `method_added` and `singleton_method_added` are callbacks ran upon method definition

These callbacks are useful to write testing frameworks for instance:
`inherited` lets you know which classes are test classes, `method_added` lets
you intercept `setup`, `teardown` and `test_*` methods.

Ruby has `local_variables`, `global_variables` and `instance_variables`
available to let programs inspect their runtimes.

To inspect the current stack: `caller` is a function returning an array of
callsites. It can be called from anywhere.

## Functional programming in Ruby
* `Object#freeze` and `Object#frozen?` are ways to make objects immutable
* `# frozen_string_literal: true` at the top of a file auto-freezes all string
  literals in that file.
* `curry` returns a curried function: `add = -> (a, b, c) { a + b + c };
  curried = add.curry; curried[2][4][8]`. `curry` takes an optional argument to
  indicate the arity at which it should evaluate (for instance: `add4 = ->
  (*nums) { nums.reduce(:+) }.curry(4)`, then `add4[1][2][3][4]`)
* tail recursive functions: if the last instruction of a function is a call to itself.

Ruby has `itself` as an "identity" function, and `yield_self` (which is the same than `tap`, but returns the result of the block passed in:

```ruby
"Hello".tap { |s| s.upcase }
=> "Hello"

"Hello".yield_self { |s| s.upcase }
=> "HELLO"
```

That's all folks!
