module MyMod
  def triple(num)
    num*3
  end
end

class CustomNumber
  include MyMod
end

puts CustomNumber.new.triple 3
