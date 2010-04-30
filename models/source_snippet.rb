# A lightweight version of Source, used for embedding
class SourceSnippet
  
  include MongoMapper::EmbeddedDocument
  
  key :title,           String
  key :slug,            String
  key :description,     String
  key :source_type,     String
  key :url,             String
  key :source_id,       ObjectId
  key :organization_id, ObjectId

  # == Associations
  
  belongs_to :organization

  # == Class Methods
  
  # Create a new snippet based on a Source
  def self.new_from_source(source)
    self.new({
      :title           => source.title,
      :slug            => source.slug,
      :description     => source.source_type,
      :url             => source.url,
      :source_id       => source.id,
      :organization_id => source.organization_id,
    })
  end
  
  # == Various Instance Methods

end
