
get '/view/workplan' do
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

def select_workplans_by_task(hideClosed)
  con = ActiveRecord::Base.connection
  sql = ""
  sql += "select"
  sql += " pl.*,"
  sql += " task_cd as id,"
  sql += " task_cd as work_plan_cd,"
  sql += " parent_cd as parent,"
  sql += " pl.name as text,"
  sql += " pl.name as name,"
  sql += " start_dt as start_date,"
  sql += " end_dt as end_date,"
  sql += " pl.sort_order as sort_order"
  sql += " from t_task pl"
  if(hideClosed)
    sql += " where pl.status_type <> 'TS06CL'"
  end
  sql += " order by pl.sort_order asc"
  rows = con.select_all(sql)
  rows
end

get '/workplans' do
  rows = select_workplans_by_task(true)
  rows.to_json(:include => {:user_info => {}})
end

get '/workplans/with_closed' do
  rows = select_workplans_by_task(false)
  rows.to_json(:include => {:user_info => {}})
end


post '/workplans', provides: :json do
  svc = TaskSvc.new()
  target = JSON.parse(request.body.read)

  # if (target["solution_cd"] == nil) || (target["solution_cd"] == "")
  #   return {success: false, message: "Solution is not designated.", data: target}.to_json
  # end

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
  # task["task_type"] = "TT01TS"
  task["task_type"] = target["task_type"]
  task["name"] = target["name"]
  task["status_type"] = target["status_type"]
  task["priority_type"] = target["priority_type"]
  task["description"] = ""
  task["parent_cd"] = (target["parent_cd"] != nil)? target["parent_cd"] : ""
  task["root_parent_cd"] = ""
  task["path"] = ""
  task["start_dt"] = target["start_date"]
  task["end_dt"] = target["end_date"]
  if ((target["task_cd"] != nil) && (target["task_cd"] != ""))
    task.sort_order = target["sort_order"]
  end
  task["progress"] = target["progress"]
  task["user_cd"] = target["user_cd"]
  task["description"] = target["description"]

  task.save()
  if(task.parent_cd != "")
    svc.link(task.task_cd, task.parent_cd, "TR02PR")
  else
    svc.set_parent_root(task.task_cd)
  end

  {success: true, message: "Register success", data: task}.to_json

  # target.to_json()
  task.to_json()
end

delete '/workplans/:cd' do
  taskSvc = TaskSvc.new()
  taskSvc.delete_by_cd(params[:cd])
  {success: true, message: "Delete success", data: nil}.to_json
end


