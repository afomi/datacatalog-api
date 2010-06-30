# Sources that are of type "dataset" can have one or more downloads that point
# to the physical dataset files.
class Download

  include MongoMapper::Document
  include Validators

  # == Attributes

  key :url,       String
  key :format,    String
  key :preview,   String
  key :size,      Hash
  key :source_id, ObjectId
  timestamps!
  
  # == Indices

  # == Associations

  belongs_to :source

  protected

  # == Validations

  include UrlValidator

  validates_presence_of :format
  validates_presence_of :url
  validates_presence_of :source_id
  validate :validate_url

  validate :general_validation
  def general_validation
    errors.add(:source_id, "must be valid") if source.nil?
  end

  before_validation :clean_size
  def clean_size
    h = size
    h['bytes']  = Try.to_i_or_f(size['bytes'])  if size['bytes']
    h['number'] = Try.to_i_or_f(size['number']) if size['number']
    self.size = h
  end
  
  SIZE_KEYS = %w(bytes number unit)
  UNIT_VALUES = %w(B KB MB TB PB EB)
  
  validate :validate_size
  def validate_size
    return if size.empty?
    if (size.keys - SIZE_KEYS).length > 0
      errors.add(:size, "only these keys are allowed : #{SIZE_KEYS}")
    end

    bytes  = size['bytes']
    number = size['number']
    unit   = size['unit']

    expect_integer_or_float(number, :size, :number)
    expect_integer_or_float(bytes, :size, :bytes)
    
    unless UNIT_VALUES.include?(unit)
      errors.add(:size, "unit must be one of: #{UNIT_VALUES.join(' ')}")
    end
  end

  # == Class Methods

  # == Various Instance Methods

end
