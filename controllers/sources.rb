module DataCatalog

  class Sources < Base
  
    resource "sources" do
      model Source

      read_only :rating_stats
      read_only :updates_per_year
      read_only :created_at
      read_only :updated_at

      callback :before_create do
        validate_custom_before_create(params["custom"])
      end

      callback :before_update do
        custom = params["custom"]
        validate_custom_before_update(custom)
        params["custom"] = self.class.merge_custom_fields(@document.custom, custom)
      end
    end

    CUSTOM_ATTRIBUTES = %w(label description type value)
    
    def validate_custom_before_create(custom)
      return if custom.nil?
      custom.length.times do |i|
        unless custom.include?(i.to_s)
          error 400, { "errors" => "malformed custom field" }.to_json
        end
      end
      errors = []
      custom.each do |field, attrs|
        self.class.missing_custom_attrs(attrs).each do |attr|
          errors << "custom[#{field}] is missing attribute: #{attr}"
        end
        self.class.invalid_custom_attrs(attrs).each do |attr|
          errors << "custom[#{field}] has invalid attribute: #{attr}"
        end
      end
      unless errors == []
        error 400, { "errors" => errors }.to_json 
      end
    end

    def validate_custom_before_update(custom)
      return if custom.nil?
      errors = []
      custom.each do |field, attrs|
        return if attrs.nil?
        self.class.invalid_custom_attrs(attrs).each do |attr|
          errors << "custom[#{field}] has invalid attribute: #{attr}"
        end
      end
      unless errors == []
        error 400, { "errors" => errors }.to_json
      end
    end

    def self.merge_custom_fields(old_custom, new_custom)
      return if new_custom.nil?
      return new_custom if old_custom.nil?
      old_custom.to_hash.merge(new_custom) do |key, left, right|
        right.nil? ? nil : left.merge(right)
      end
    end
    
    def self.missing_custom_attrs(hash)
      CUSTOM_ATTRIBUTES - hash.keys
    end
    
    def self.invalid_custom_attrs(hash)
      hash.keys - CUSTOM_ATTRIBUTES
    end
  end

end
