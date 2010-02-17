class Slug
  
  # Convert +text+ into a slug appropriate for +document+.
  def self.make(text, document)
    slug = prefix = make_prefix(text, document)
    Iterate.starting_at(2) do |n|
      break unless document.class.first(:slug => slug)
      slug = "#{prefix}-#{n}"
    end
    slug
  end

  # Convert +text+ into a slug prefix appropriate for +document+.
  #
  # A slug prefix is not guaranteed to be unique. Therefore, this method
  # method should not be used directly in your application. Use Slug.make
  # instead.
  #
  # Adapted from ActiveSupport's parameterize
  # http://github.com/rails/rails/blob/ea0e41d8fa5a132a2d2771e9785833b7663203ac/activesupport/lib/active_support/inflector.rb#L259
  def self.make_prefix(text, document, separator = "-")
    slug = text.to_s.downcase
    slug.gsub!(/[^a-z0-9]+/, separator)
    unless separator.nil? || separator == ''
      regex = Regexp.escape(separator)
      slug.gsub!(/#{regex}{2,}/, separator)
      slug.gsub!(/^#{regex}|#{regex}$/, '')
    end
    if slug.blank?
      document.id ? document.id.to_s : slug.object_id.to_s
    else
      slug
    end
  end

end
