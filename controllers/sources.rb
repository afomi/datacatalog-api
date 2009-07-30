get '/sources' do
  Source.find(:all).to_json
end

get '/sources/:id' do |id|
  Source.find(id).to_json
end

post '/sources' do
  source = Source.create(params)
  source.to_json
end

put '/sources/:id' do |id|
  source = Source.update(id, params)
  source.to_json
end

delete '/sources/:id' do |id|
  source = Source.find(id)
  source.destroy
  { "_id" => id }.to_json
end
