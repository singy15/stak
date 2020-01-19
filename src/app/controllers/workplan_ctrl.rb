get '/view/workplan' do
  authenticate!

  # if logged_in?
  #   p "logged in"
  # else
  #   p "not logged in"
  # end

  @view_title = "Workplan"
  @view_subtitle = ""

  typeSvc = TypeSvc.new()
  @key_value_user = typeSvc.kv_user()
  @key_value_work_type = typeSvc.kv_work_type()
  @key_value_task_status_type = typeSvc.kv_task_status()
  @key_value_task_type = typeSvc.kv_task_type()
  @key_value_task_priority_type = typeSvc.kv_task_priority()
  @key_value_task_task_relation_type = typeSvc.kv_task_task_relation()
  @key_value_solution = typeSvc.kv_solution()

  @view_content = erb :part_workplan
  @view_content_bottom = erb :part_workplan_bottom
  erb :template
end

get '/workplans' do
  authenticate!
  svc = TaskSvc.new()
  rslt = svc.select_workplans_by_task(true)
  ControllerUtil.response(rslt.success, rslt.msg, JSON.parse(rslt.data.to_json(:include => {:user_info => {}})))
end

get '/workplans/with_closed' do
  authenticate!
  svc = TaskSvc.new()
  rslt = svc.select_workplans_by_task(false)
  ControllerUtil.response(rslt.success, rslt.msg, JSON.parse(rslt.data.to_json(:include => {:user_info => {}})))
end


post '/workplans', provides: :json do
  authenticate!
  target = JSON.parse(request.body.read)
  svc = TaskSvc.new()
  rslt = svc.upsert_workplan(target)
  ControllerUtil.response(rslt.success, rslt.msg, rslt.data)
end

delete '/workplans/:cd' do
  authenticate!
  svc = TaskSvc.new()
  rslt = svc.delete_by_cd(params[:cd])
  ControllerUtil.response(rslt.success, rslt.msg, rslt.data)
end


