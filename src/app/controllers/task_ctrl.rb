
get '/view/tasks' do
  @view_title = "Tasks"
  @view_subtitle = ""

  typeSvc = TypeSvc.new()
  @key_value_user = typeSvc.kv_user()
  @key_value_task_status_type = typeSvc.kv_task_status()
  @key_value_task_type = typeSvc.kv_task_type()
  @key_value_task_priority_type = typeSvc.kv_task_priority()
  @key_value_task_task_relation_type = typeSvc.kv_task_task_relation()
  @key_value_solution = typeSvc.kv_solution()

  @view_content = erb :part_task_list
  @view_content_bottom = erb :part_task_list_bottom
  erb :template
end

get '/tasks' do
  svc = TaskSvc.new()
  @tasks = svc.select_by_condition(params)
end

get '/tasks/:cd' do
  svc = TaskSvc.new()
  @tasks = svc.select_by_cd(params[:cd])
end

delete '/tasks/:cd' do
  svc = TaskSvc.new()
  svc.delete_by_cd(params[:cd])
  ControllerUtil.response(true, "Delete success", nil)
end

delete '/batch/tasks' do
  target = JSON.parse(request.body.read)
  svc = TaskSvc.new()
  svc.batch_delete(target["rows"])
  ControllerUtil.response(true, "Delete success", target)
end

post '/batch/tasks' do
  target = JSON.parse(request.body.read)
  svc = TaskSvc.new()
  svc.batch_update(target)
  ControllerUtil.response(true, "Batch update success", target)
end

post '/tasks', provides: :json do
  target = JSON.parse(request.body.read)
  svc = TaskSvc.new()
  svc.upsert(target)
end

post '/link/task_task' do
  target = JSON.parse(request.body.read)
  svc = TaskSvc.new()
  svc.link(target["taskCdA"], target["taskCdB"], target["relType"])
  ControllerUtil.response(true, "Link success.", target)
end

post '/unlink/task_task' do
  target = JSON.parse(request.body.read)
  svc = TaskSvc.new()
  svc.unlink(target["taskCdA"], target["taskCdB"], target["relType"])
  ControllerUtil.response(true, "Link success.", target)
end


