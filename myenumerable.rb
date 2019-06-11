class SaysHi
  include Enumerable
  def each
    yield 'oh'
    yield 'hi'
    yield 'how'
    yield 'are'
    yield 'you'
    yield 'today'
  end
end

puts SaysHi.new.map { |word| word.upcase }
puts SaysHi.new.find { |word| word.start_with? 'h' }
