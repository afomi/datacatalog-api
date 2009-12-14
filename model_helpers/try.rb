class Try
  
  def self.to_i_or_f(x)
    if x.nil?
      nil
    elsif to_i?(x)
      Integer(x)
    elsif to_f?(x)
      Float(x)
    else
      x
    end
  end

  def self.to_i(x)
    begin
      Integer(self)
    rescue ArgumentError
      x
    end
  end

  def self.to_i?(x)
    begin
      Integer(x)
      true
    rescue ArgumentError
      false
    end
  end

  def self.to_f?(x)
    begin
      Float(x)
      true
    rescue ArgumentError
      false
    end
 end
  
end
