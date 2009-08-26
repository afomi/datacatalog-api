get '/notes' do
  require_admin_privileges
  notes = Note.find(:all)
  notes.to_json
end

get '/notes/:id' do |id|
  require_admin_privileges
  id = params.delete("id")
  note = Note.find_by_id(id)
  error 404, [].to_json unless note
  note.to_json
end

post '/notes' do
  require_admin_privileges
  id = params.delete("id")
  validate_note_params
  note = create_note_from_params
  note.to_json
end

put '/notes/:id' do
  require_admin_privileges
  id = params.delete("id")
  note = Note.find_by_id(id)
  error 404, [].to_json unless note
  validate_note_params
  note = Note.update(id, params)
  note.to_json
end

delete '/notes/:id' do
  require_admin_privileges
  id = params.delete("id")
  note = Note.find_by_id(id)
  error 404, [].to_json unless note
  note.destroy
  { "id" => id }.to_json
end
