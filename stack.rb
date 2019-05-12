require_relative 'stacklike'

class Stack
  include Stacklike
end

s = Stack.new
s.push(1)
puts s.pop
