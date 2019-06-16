module M
  def self.included(cl)
    puts "M just got included in #{cl}"
  end

  def self.prepended(cl)
    puts "M just got prepended in #{cl}"
  end

  def self.extended(obj)
    puts "M just got extended by #{obj}"
  end
end

class C
  include M
  def self.inherited(subclass)
    puts "C just got subclassed by #{subclass}"
  end
  def self.method_added(m)
    puts "#{self} got a new (instance) method: #{m}"
  end
  def foo
    puts "inside of C#foo"
  end
end

class D < C
  prepend M
  def self.singleton_method_added(m)
    puts "#{self} got a new singleton method: #{m}"
  end
  def self.const_missing(const)
    return 42
  end
end

puts "D has all the constants: #{D::SOME_UNDEFINED_CONSTANT}"
d = D.new
d.extend(M)
