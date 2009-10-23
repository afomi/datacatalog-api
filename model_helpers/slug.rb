class Slug
  
  # Adapted from ActiveSupport's parameterize
  # http://github.com/rails/rails/blob/ea0e41d8fa5a132a2d2771e9785833b7663203ac/activesupport/lib/active_support/inflector.rb#L259
  def self.make(string, doc, separator = "-")
    slug = string.downcase
    slug.gsub!(/[^a-z0-9]+/, separator)
    unless separator.nil? || separator == ''
      regex = Regexp.escape(separator)
      slug.gsub!(/#{regex}{2,}/, separator)
      slug.gsub!(/^#{regex}|#{regex}$/, '')
    end
    prevent_blank(slug, doc)
  end
  
  def self.prevent_blank(slug, doc)
    if slug.blank?
      doc_id = doc.id
      doc_id ? doc_id.to_s : slug.object_id.to_s
    else
      slug
    end
  end

end
