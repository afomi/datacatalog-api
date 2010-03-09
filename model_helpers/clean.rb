class Clean
  
  def self.kronos_hash(x)
    h = x
    %w(year month day).each do |part|
      unless x[part].blank?
        h[part] = Try.to_i(x[part])
      end
    end
    h
  end

end
