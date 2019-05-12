module Stacklike
  def stack
    @stack ||= []
  end

  def push(obj)
    stack.push(obj)
  end

  def pop
    stack.pop
  end
end
