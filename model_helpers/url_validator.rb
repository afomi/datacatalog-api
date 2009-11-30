module UrlValidator
  
  def validate_url
    return if url.blank?
    uri = URI.parse(url)
    unless uri.absolute?
      errors.add(:url, "URI must be absolute")
    end
    unless %w(http ftp).include?(uri.scheme)
      errors.add(:url, "URI scheme must be http or ftp")
    end
  rescue URI::InvalidURIError => e
    errors.add(:url, "Invalid URI: #{e})")
  end
  
end
