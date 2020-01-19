
get '/view/tasks' do
  authenticate!
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
  authenticate!
  svc = TaskSvc.new()
  rslt = svc.select_by_condition(params)
  ControllerUtil.response_grid(rslt.total, rslt.rows)
end

get '/tasks/:cd' do
  authenticate!
  svc = TaskSvc.new()
  rslt = svc.select_by_cd(params[:cd])
  ControllerUtil.response(rslt.success, rslt.msg, JSON.parse(TTask.json(rslt.data)))
end

delete '/tasks/:cd' do
  authenticate!
  svc = TaskSvc.new()
  rslt = svc.delete_by_cd(params[:cd])
  ControllerUtil.response(rslt.success, rslt.msg, rslt.data)
end

delete '/batch/tasks' do
  authenticate!
  target = JSON.parse(request.body.read)
  svc = TaskSvc.new()
  rslt = svc.batch_delete(target["rows"])
  ControllerUtil.response(rslt.success, rslt.msg, rslt.data)
end

post '/batch/tasks' do
  authenticate!
  target = JSON.parse(request.body.read)
  svc = TaskSvc.new()
  rslt = svc.batch_update(target)
  ControllerUtil.response(rslt.success, rslt.msg, rslt.data)
end

post '/tasks', provides: :json do
  authenticate!
  target = JSON.parse(request.body.read)
  svc = TaskSvc.new()
  rslt = svc.upsert(target)
  ControllerUtil.response(rslt.success, rslt.msg, rslt.data)
end

post '/link/task_task' do
  authenticate!
  target = JSON.parse(request.body.read)
  svc = TaskSvc.new()
  rslt = svc.link(target["taskCdA"], target["taskCdB"], target["relType"])
  ControllerUtil.response(rslt.success, rslt.msg, rslt.data)
end

post '/unlink/task_task' do
  authenticate!
  target = JSON.parse(request.body.read)
  svc = TaskSvc.new()
  rslt = svc.unlink(target["taskCdA"], target["taskCdB"], target["relType"])
  ControllerUtil.response(rslt.success, rslt.msg, rslt.data)
end


