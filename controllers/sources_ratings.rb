get '/sources/:source_id/ratings' do
  require_admin
  source_id = params.delete("source_id")
  source = Source.find_by_id(source_id)
  error 404, [].to_json unless source
  source.ratings.to_json
end

get '/sources/:source_id/ratings/:rating_id' do
  require_admin
  source_id = params.delete("source_id")
  rating_id = params.delete("rating_id")
  source = Source.find_by_id(source_id)
  error 404, [].to_json unless source
  rating = source.ratings.find { |x| x.id == rating_id }
  error 404, [].to_json unless rating
  rating.to_json
end

post '/sources/:source_id/ratings' do
  require_admin
  source_id = params.delete("source_id")
  source = Source.find_by_id(source_id)
  error 404, [].to_json unless source
  validate_rating_params
  rating = Rating.new(params)
  source.ratings << rating
  error 500, [].to_json unless source.save
  response.status = 201
  response.headers['Location'] = full_uri "/sources/#{source_id}/ratings/#{rating.id}"
  rating.to_json
end

put '/sources/:source_id/ratings/:rating_id' do
  require_admin
  source_id = params.delete("source_id")
  rating_id = params.delete("rating_id")
  source = Source.find_by_id(source_id)
  error 404, [].to_json unless source
  validate_rating_params
  rating = source.ratings.find { |x| x.id == rating_id }
  error 404, [].to_json unless rating
  rating_index = source.ratings.index(rating)
  validate_rating_params
  rating.attributes = params
  source.ratings[rating_index] = rating
  error 500, [].to_json unless source.save
  rating.to_json
end

delete '/sources/:source_id/ratings/:rating_id' do
  require_admin
  source_id = params.delete("source_id")
  rating_id = params.delete("rating_id")
  source = Source.find_by_id(source_id)
  error 404, [].to_json unless source
  keys = source.ratings
  rating = source.ratings.find { |x| x.id == rating_id }
  error 404, [].to_json unless rating
  source.ratings.delete(rating)
  source.save!
  { "id" => rating_id }.to_json
end
