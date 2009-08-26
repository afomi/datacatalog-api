get '/comments' do
  require_admin_privileges
  comments = Comment.find(:all)
  comments.to_json
end

get '/comments/:id' do |id|
  require_admin_privileges
  id = params.delete("id")
  comment = Comment.find_by_id(id)
  error 404, [].to_json unless comment
  comment.to_json
end

post '/comments' do
  require_admin_privileges
  id = params.delete("id")
  validate_comment_params
  comment = create_comment_from_params
  comment.to_json
end

put '/comments/:id' do
  require_admin_privileges
  id = params.delete("id")
  comment = Comment.find_by_id(id)
  error 404, [].to_json unless comment
  validate_comment_params
  comment = Comment.update(id, params)
  comment.to_json
end

delete '/comments/:id' do
  require_admin_privileges
  id = params.delete("id")
  comment = Comment.find_by_id(id)
  error 404, [].to_json unless comment
  comment.destroy
  { "id" => id }.to_json
end
