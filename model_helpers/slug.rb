class Slug
  
  # Adapted from ActiveSupport's parameterize
  # http://github.com/rails/rails/blob/ea0e41d8fa5a132a2d2771e9785833b7663203ac/activesupport/lib/active_support/inflector.rb#L259
  def self.make(thing, doc, separator = "-")
    slug = thing.to_s.downcase
    slug.gsub!(/[^a-z0-9]+/, separator)
    unless separator.nil? || separator == ''
      regex = Regexp.escape(separator)
      slug.gsub!(/#{regex}{2,}/, separator)
      slug.gsub!(/^#{regex}|#{regex}$/, '')
    end
    if slug.blank?
      doc.id ? doc.id.to_s : slug.object_id.to_s
    else
      slug
    end
  end

end
