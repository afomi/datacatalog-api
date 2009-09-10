class RatingObserver < MongoMapper::Observer
  
  observe Rating
  
  def after_create(rating)
    doc = rating.find_rated_document!
    doc.ratings_count += 1
    doc.ratings_total += rating.value
    doc.save
  end
  
  def before_update(rating)
    rating_from_db = Rating.find_by_id(rating.id)
    rating.previous_value = rating_from_db.value
  end
  
  def after_update(rating)
    doc = rating.find_rated_document!
    doc.ratings_total += (rating.value - rating.previous_value)
    doc.save
  end

  def after_destroy(rating)
    doc = rating.find_rated_document
    return if doc.nil?
    doc.ratings_count -= 1
    doc.ratings_total -= rating.value
    doc.save
  end
  
end

RatingObserver.instance
