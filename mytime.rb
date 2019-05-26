class Integer
  def mytime
    n=0
    until n=self
      yield n
      n+=1
    end
  end
end

5.times { |i| puts "iteration ##{i}" }
