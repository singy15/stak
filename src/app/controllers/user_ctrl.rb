
get '/view/users' do
  @view_title = "Users"
  @view_subtitle = ""
  @view_content = erb :part_user_list
  @view_content_bottom = erb :part_user_list_bottom
  erb :template
end

get '/users' do
  userSvc = UserSvc.new()
  MUser.json(userSvc.select_all_order())
end

post '/users', provides: :json do
  target = JSON.parse(request.body.read)
  svc = UserSvc.new()
  svc.upsert(target)
end

delete '/users/:cd' do
  svc = UserSvc.new()
  svc.delete_by_cd(params[:cd])
  {success: true, message: "Delete success", data: nil}.to_json
end

