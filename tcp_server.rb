require 'socket'

s = TCPServer.new(3939)

while (conn =  s.accept)
  Thread.new(conn) do |c|
    conn.puts 'Welcome. Name please?'
    name = c.gets.chomp
    conn.puts "Nice to meet you #{name}"
    conn.puts 'Bye now!'
    conn.close
  end
end
