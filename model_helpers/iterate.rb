class Iterate
  
  def self.starting_at(n)
    loop do
      yield n
      n += 1
    end
  end

end