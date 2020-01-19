
get '/view/users' do
  authenticate!
  @view_title = "Users"
  @view_subtitle = ""
  @view_content = erb :part_user_list
  @view_content_bottom = erb :part_user_list_bottom
  erb :template
end

get '/users' do
  authenticate!
  userSvc = UserSvc.new()
  rslt = userSvc.select_all_order()
  ControllerUtil.response_grid(rslt.total, rslt.rows)
end

post '/users', provides: :json do
  authenticate!
  target = JSON.parse(request.body.read)
  svc = UserSvc.new()
  rslt = svc.upsert(target)
  ControllerUtil.response(rslt.success, rslt.msg, rslt.data)
end

delete '/users/:cd' do
  authenticate!
  svc = UserSvc.new()
  rslt = svc.delete_by_cd(params[:cd])
  ControllerUtil.response(rslt.success, rslt.msg, rslt.data)
end

