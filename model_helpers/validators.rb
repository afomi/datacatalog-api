module Validators

  KRONOS_DATE_KEYS = %w(day month year)
  MIN_YEAR = 1900
  MAX_YEAR = Time.now.year

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
  
  def expect_kronos_hash(x, field)
    return if x.blank?
    if (x.keys - KRONOS_DATE_KEYS).length > 0
      errors.add(field, "only these keys are allowed : #{RELEASED_KEYS}")
      return
    end
  
    year, month, day = x['year'], x['month'], x['day']
    expect_integer(year,  field, :year)
    expect_integer(month, field, :month)
    expect_integer(day,   field, :day)
    
    if !year.blank? && !((MIN_YEAR .. MAX_YEAR) === year)
      errors.add(field, "year must be between #{MIN_YEAR} and #{MAX_YEAR}")
    end
    if !month.blank? && !((1 .. 12) === month)
      errors.add(field, "month must be between 1 and 12")
    end
    if !day.blank? && !((1 .. 31) === day)
      errors.add(field, "day must be between 1 and 31")
    end
    
    if !day.blank? && month.blank?
      errors.add(field, "month required if day is present")
    end
    if !day.blank? && year.blank?
      errors.add(field, "year required if day is present")
    end
    if !month.blank? && year.blank?
      errors.add(field, "year required if month is present")
    end
  end

end
