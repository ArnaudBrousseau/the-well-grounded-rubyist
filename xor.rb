class String
  def ^(key)
    key_enum = key.each_byte.cycle
    each_byte.map { |b| b ^ key_enum.next }.pack('C*')
  end
end

str = 'Answer is: 42'
key = 'secret key'

obfuscated = str ^ 'secret key'
puts "obfuscated: #{obfuscated}"
clear_again = obfuscated ^ key
puts "clear, again: #{clear_again}"
