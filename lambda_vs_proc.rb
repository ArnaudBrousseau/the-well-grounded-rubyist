def return_test(&p)
  puts 'before lambda'
  l = lambda { puts 'inside lambda'; return }
  l.call
  puts 'after lambda'

  puts 'before proc'
  p = proc { puts 'inside proc'; return }
  p.call
  # won't be printed!
  puts 'after proc'
end

return_test
