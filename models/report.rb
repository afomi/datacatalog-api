# A report is:
# * intended for a curator
# * created by an importer
#
# Attributes:
# - message
#
#
class Report

  include MongoMapper::Document

  # == Attributes

  key :user_id,  String # the creator
  key :text,     String # plain text, created by importer
  key :object,   Hash   # optional hash object, created by importer
  key :status,   String # see STATUS_TYPES below
  key :log,      String # plain text field to log a curator's response
  timestamps!

  # == Indices

  # == Associations

  belongs_to :user

  # == Validations

  validates_presence_of :text
  validates_presence_of :user_id

  validate :validate_user
  def validate_user
    errors.add(:user_id, "must be valid") if user.nil?
  end
  protected :validate_user

  STATUS_TYPES = %w(new open closed)

  validate :validate_status
  def validate_status
    unless STATUS_TYPES.include?(status)
      errors.add(:status, "must be one of: #{STATUS_TYPES.join(', ')}")
    end
  end
  protected :validate_status

  # == Class Methods

  # == Various Instance Methods

end
