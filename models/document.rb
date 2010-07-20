# A collaboratively edited document, such as a wiki page.
#
#   source_id points to the associated source.
#   previous_id points to the previous draft.
#   user_id points to the most recent editor.
class Document

  include MongoMapper::Document

  # == Attributes

  key :text,        String
  key :source_id,   ObjectId
  key :user_id,     ObjectId
  key :previous_id, ObjectId
  key :next_id,     ObjectId
  timestamps!

  # == Indices

  # == Associations
  
  belongs_to :source
  belongs_to :user
  
  protected

  # == Validations
  
  validates_presence_of :text
  validates_presence_of :source_id
  validates_presence_of :user_id

  validate :general_validation
  def general_validation
    errors.add(:user_id, "must be valid") if user.nil?
    errors.add(:source_id, "must be valid") if source.nil?
  end

  # == Class Methods

  # == Various Instance Methods
  
  public

  # Creates a new Document version based on +self+.
  #
  # Note: does not save the current document, by design.
  def create_new_version!
    if self.new?
      raise DataCatalog::Error, "document must be saved before versioning"
    end
    unless self.id
      raise DataCatalog::Error, "expected document to have an id"
    end
    copy = self.dup
    copy.id = BSON::ObjectID.new.to_s
    copy.next_id = self.id
    copy.save!
    self.previous_id = copy.id
    copy
  end

end
