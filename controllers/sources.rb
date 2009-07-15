require_relative 'models/source'

get '/sources' do
  content_type :json
  Source.find(:all).to_json
end

get '/sources/:id' do |id|
  content_type :json
  Source.find(id).to_json
end

post '/sources' do
  content_type :json
  source = Source.create(params)
  source.to_json
end

put '/sources/:id' do |id|
  content_type :json
  source = Source.update(id, params)
  # source = Source.create(params)
  source.to_json
end

delete '/sources/:id' do |id|
  content_type :json
  source = Source.find(id)
  source.destroy
  { "_id" => id }.to_json
end
