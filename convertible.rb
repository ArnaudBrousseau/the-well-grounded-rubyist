module Convertible
  def c2f(celsius)
    32 + (celsius.to_f) * 9 / 5
  end

  def f2c(fahrenheit)
    (fahrenheit.to_f - 32) * 5 / 9
  end
end

class Thermometer
  extend Convertible
end

# Convertible methods available as class methods
puts Thermometer.f2c(100)
