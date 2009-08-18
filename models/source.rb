class Source

  include MongoMapper::Document

  key :url, String, :index => true
  many :ratings

  alias original_to_json to_json
  def to_json(options = nil)
    original_to_json({
      :methods => :id,
      :except  => :_id
    })
  end

end
