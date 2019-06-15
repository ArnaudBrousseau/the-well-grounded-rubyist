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

puts Foo.any? { |i| i > 3 }
puts Foo.any? { |i| i > 0 }
