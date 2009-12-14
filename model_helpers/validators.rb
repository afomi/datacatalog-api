module Validators

  def expect_integer(x, field, subfield)
    return if x.blank?
    unless x.is_a?(Integer)
      errors.add(field, "#{subfield} must be an integer if present")
    end
  end
  
  def expect_float(x, field, subfield)
    return if x.blank?
    unless x.is_a?(Float)
      errors.add(field, "#{subfield} must be a float if present")
    end
  end
  
  def expect_integer_or_float(x, field, subfield)
    return if x.blank?
    unless x.is_a?(Integer) || x.is_a?(Float)
      errors.add(field, "#{subfield} must be an integer or float if present")
    end
  end

end
