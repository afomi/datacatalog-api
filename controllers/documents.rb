get '/documents' do
  validate_admin_privileges
  documents = Document.find(:all)
  documents.to_json
end

get '/documents/:id' do |id|
  validate_admin_privileges
  id = params.delete("id")
  document = Document.find_by_id(id)
  error 404, [].to_json unless document
  document.to_json
end

post '/documents' do
  validate_admin_privileges
  id = params.delete("id")
  validate_document_params
  document = create_document_from_params
  document.to_json
end

put '/documents/:id' do
  validate_admin_privileges
  id = params.delete("id")
  document = Document.find_by_id(id)
  error 404, [].to_json unless document
  validate_document_params
  document = Document.update(id, params)
  document.to_json
end

delete '/documents/:id' do
  validate_admin_privileges
  id = params.delete("id")
  document = Document.find_by_id(id)
  error 404, [].to_json unless document
  document.destroy
  { "id" => id }.to_json
end
