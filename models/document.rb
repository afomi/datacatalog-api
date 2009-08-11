# A collaboratively edited document, such as a wiki page.
class Document

  include MongoMapper::Document

  key :text,            String
  key :source_id,       MongoID
  key :user_id,         MongoID
  key :previous_doc_id, MongoID

  alias original_to_json to_json
  def to_json(options = nil)
    original_to_json({
      :methods => :id,
      :except  => :_id
    })
  end

end
