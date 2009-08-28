# A user can rate a source.
class Rating

  include MongoMapper::Document

  key :value,      Integer
  key :text,       String
  key :user_id,    String
  key :source_id,  String

  alias original_to_json to_json
  def to_json(options = nil)
    original_to_json({
      :methods => :id,
      :except  => :_id
    })
  end

end
