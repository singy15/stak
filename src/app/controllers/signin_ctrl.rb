get '/view/signin' do
  @view_title = "Signin"
  @view_subtitle = ""
  @view_content = erb :part_signin
  # @view_content_bottom = erb :part_workplan_bottom
  @view_content_bottom = ""
  erb :template
  # erb :signin
end

post '/signin' do
  p params["user"]
  p params["password"]
  users = MUser.where(login_id: params["user"], password: params["password"])
  if users.size == 1
    session[:user_id] = users[0][:user_cd]
    redirect session[:original_request]
  end
  redirect '/view/redirect'
end

get '/signout' do
  session[:user_id] = nil
  redirect '/view/signin'
end

