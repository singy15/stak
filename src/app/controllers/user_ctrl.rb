
get '/view/users' do
  @view_title = "Users"
  @view_subtitle = ""
  # @users = 
  @view_content = erb :part_user_list
  @view_content_bottom = erb :part_user_list_bottom
  erb :template
end

get '/users' do
  userSvc = UserSvc.new()
  MUser.json(userSvc.select_all_order())
end

post '/users', provides: :json do
  svc = UserSvc.new()

  target = JSON.parse(request.body.read)

  if (target["name"] == nil) || (target["name"] == "")
    return {success: false, message: "User name should not be blank.", data: target}.to_json
  end

  p target
  user = MUser.where(user_cd: target["user_cd"])

  if(user.length == 0) 
    user = MUser.new()

    user["user_cd"] = svc.fetch_new_cd()
    user["created"] = Time.now
    user["updated"] = Time.now
    user["created_by"] = ""
    user["updated_by"] = ""
  else
    user = user[0]
  end

  user["name"] = target["name"]

  user.save()

  {success: true, message: "Register success", data: user}.to_json
end

delete '/users/:cd' do
  svc = UserSvc.new()
  svc.delete_by_cd(params[:cd])
  {success: true, message: "Delete success", data: nil}.to_json
end

