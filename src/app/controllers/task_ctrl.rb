
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
  taskSvc = TaskSvc.new()
  @tasks = taskSvc.select_by_condition(params)
end

get '/tasks/:cd' do
  taskSvc = TaskSvc.new()
  @tasks = taskSvc.select_by_cd(params[:cd])
end

delete '/tasks/:cd' do
  taskSvc = TaskSvc.new()
  taskSvc.delete_by_cd(params[:cd])
  ControllerUtil.response(true, "Delete success", nil)
end

delete '/batch/tasks' do
  target = JSON.parse(request.body.read)

  target["rows"].each do |e|
    TTask.destroy(e["task_cd"])
    TTaskTaskRel.where(task_cd_a: e["task_cd"]).delete_all()
    TTaskTaskRel.where(task_cd_b: e["task_cd"]).delete_all()
  end

  ControllerUtil.response(true, "Delete success", target)
end

post '/batch/tasks' do
  target = JSON.parse(request.body.read)

  target["rows"].each do |e|
    task = TTask.find(e["task_cd"])
    if((target["diff"]["task_type"] != nil) && (target["diff"]["task_type"] != ""))
      task.task_type = target["diff"]["task_type"]
    end
    if((target["diff"]["status_type"] != nil) && (target["diff"]["status_type"] != ""))
      task.status_type = target["diff"]["status_type"]
    end
    if((target["diff"]["name"] != nil) && (target["diff"]["name"] != ""))
      task.name = target["diff"]["name"]
    end
    if((target["diff"]["description"] != nil) && (target["diff"]["description"] != ""))
      task.description = target["diff"]["description"]
    end
    if((target["diff"]["priority_type"] != nil) && (target["diff"]["priority_type"] != ""))
      task.priority_type = target["diff"]["priority_type"]
    end
    if((target["diff"]["start_dt"] != nil) && (target["diff"]["start_dt"] != ""))
      task.start_dt = target["diff"]["start_dt"]
    end
    if((target["diff"]["end_dt"] != nil) && (target["diff"]["end_dt"] != ""))
      task.end_dt = target["diff"]["end_dt"]
    end
    task.save()
  end

  ControllerUtil.response(true, "Batch update success", target)
end


post '/tasks', provides: :json do
  svc = TaskSvc.new()

  target = JSON.parse(request.body.read)

  if (target["solution_cd"] == nil) || (target["solution_cd"] == "")
    return {success: false, message: "Solution is not designated.", data: target}.to_json
  end

  p target
  task = TTask.where(task_cd: target["task_cd"])

  if(task.length == 0) 
    task = TTask.new()

    task["task_cd"] = svc.fetch_new_cd(target["solution_cd"])
    task["created"] = Time.now
    task["updated"] = Time.now
    task["created_by"] = ""
    task["updated_by"] = ""
  else
    task = task[0]
  end


  task["solution_cd"] = target["solution_cd"]
  task["task_type"] = target["task_type"]
  task["name"] = target["name"]
  task["status_type"] = target["status_type"]
  task["priority_type"] = target["priority_type"]
  task["description"] = target["description"]
  task["parent_cd"] = (target["parent_cd"] != nil)? target["parent_cd"] : ""
  task["root_parent_cd"] = ""
  task["path"] = ""
  task["start_dt"] = target["start_dt"]
  task["end_dt"] = target["end_dt"]
  task["user_cd"] = target["user_cd"]

  task.save()
  if(task.parent_cd != "")
    svc.link(task.task_cd, task.parent_cd, "TR02PR")
  else
    svc.set_parent_root(task.task_cd)
  end

  ControllerUtil.response(true, "Register success", task)
end

post '/link/task_task' do
  target = JSON.parse(request.body.read)

  taskSvc = TaskSvc.new()
  taskSvc.link(target["taskCdA"], target["taskCdB"], target["relType"])

  ControllerUtil.response(true, "Link success.", target)
end

post '/unlink/task_task' do
  target = JSON.parse(request.body.read)

  taskSvc = TaskSvc.new()
  taskSvc.unlink(target["taskCdA"], target["taskCdB"], target["relType"])

  ControllerUtil.response(true, "Link success.", target)
end


