fahrenheit = File.read('f.data')
celsius = (fahrenheit.to_f - 32) * 5 / 9

fh = File.new('c.data', 'w')
fh.write(celsius)
fh.close
