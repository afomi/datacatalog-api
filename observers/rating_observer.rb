class RatingObserver < MongoMapper::Observer
  
  observe Rating
  
  def after_create(rating)
    doc = rated_document(rating)
    doc.ratings_count += 1
    doc.ratings_total += rating.value
    doc.save
  end
  
  def before_update(rating)
    rating_from_db = Rating.find_by_id(rating.id)
    rating.previous_value = rating_from_db.value
  end
  
  def after_update(rating)
    doc = rated_document(rating)
    doc.ratings_total += (rating.value - rating.previous_value)
    doc.save
  end
  
  protected
  
  def rated_document(rating)
    doc = case rating.kind
    when "comment" then rating.comment
    when "source"  then rating.source
    else raise "Invalid kind of rating"
    end
    raise "Associated #{rating.kind} not found" if doc.nil?
    doc
  end
  
end

RatingObserver.instance
