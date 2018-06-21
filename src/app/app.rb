
# Requires
require 'sinatra'
require './const.rb'
require './service.rb'
require './db_setting.rb'

configure :development do |c| 
  require 'sinatra/reloader' 
  c.also_reload "./const.rb" 
  c.also_reload "./service.rb" 
  c.also_reload "./db_setting.rb"
  # c.also_reload "./controllers/*.rb" 
  # c.also_reload "./init/*.rb" 
end

enable :sessions

get '/' do
  @view_title = "Welcome"
  @view_subtitle = "Welcome to Stak"
  @view_content = erb :part_top_content
  erb :template
end

get '/view/dashboard' do
  @view_title = "Dashboard"
  @view_subtitle = ""
  erb :template
end

get '/view/workplan' do
  @view_title = "Workplan"
  @view_subtitle = ""

  typeSvc = TypeSvc.new()
  @key_value_user = typeSvc.kv_user()
  @key_value_work_type = typeSvc.kv_work_type()

  @view_content = erb :part_workplan
  erb :template
end

get '/view/tasks' do
  @view_title = "Tasks"
  @view_subtitle = ""

  typeSvc = TypeSvc.new()
  @key_value_task_status_type = typeSvc.kv_task_status()
  @key_value_task_type = typeSvc.kv_task_type()
  @key_value_task_priority_type = typeSvc.kv_task_priority()
  @key_value_task_task_relation_type = typeSvc.kv_task_task_relation()
  @key_value_solution = typeSvc.kv_solution()

  @view_content = erb :part_task_list
  erb :template
end

get '/view/solutions' do
  @view_title = "Solutions"
  @view_subtitle = ""
  @solutions = TSolution.all.to_json
  @status_types = CType.where(type_category: "SS").order("sort_order").to_json
  typeSvc = TypeSvc.new()
  @key_value_solution_status_type = typeSvc.kv_solution_status_type()
  @view_content = erb :part_solution_list
  erb :template
end

get '/view/users' do
  @view_title = "Users"
  @view_subtitle = ""
  # @users = 
  @view_content = erb :part_user_list
  erb :template
end

get '/users' do
  userSvc = UserSvc.new()
  userSvc.select_all()
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
  {success: true, message: "Delete success", data: nil}.to_json
end

delete '/batch/tasks' do
  target = JSON.parse(request.body.read)

  target["rows"].each do |e|
    TTask.destroy(e["task_cd"])
    TTaskTaskRel.where(task_cd_a: e["task_cd"]).delete_all()
    TTaskTaskRel.where(task_cd_b: e["task_cd"]).delete_all()
  end

  {success: true, message: "Delete success", data: target}.to_json
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
    task.save()
  end

  {success: true, message: "Batch update success", data: target}.to_json
end

delete '/solutions/:cd' do
  @task = TSolution.destroy(params[:cd])
  {success: true, message: "Delete success", data: nil}.to_json
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

  task.save()
  if(task.parent_cd != "")
    svc.link(task.task_cd, task.parent_cd, "TR02PR")
  else
    svc.set_parent_root(task.task_cd)
  end

  {success: true, message: "Register success", data: task}.to_json
end

put '/solutions', provides: :json do
  target = JSON.parse(request.body.read)
  p target
  info = TSolution.where(solution_cd: target["solution_cd"])

  if(info.length == 0) 
    info = TSolution.new()

    result = ActiveRecord::Base.connection.select_value(
      ActiveRecord::Base.send(
        :sanitize_sql_array,
        [ 'select sp_numbering(:numbering_type, :parent_cd)', 
          numbering_type: 'SL',
          parent_cd: ''])
    )

    info["solution_cd"] = result
    info["created"] = Time.now
    info["updated"] = Time.now
    info["created_by"] = ""
    info["updated_by"] = ""
  else
    info = info[0]
  end


  info["name"] = target["name"]
  info["status_type"] = target["status_type"]
  info.save()
  {success: true, message: "Register success", data: info}.to_json
end

get '/solutions' do
  solutions = TSolution.all
  if params["filterRules"]
    filter_rules = JSON.parse(params["filterRules"])
    p filter_rules

    filter_rules.select {|f| f["op"] == "equal" }.each do |r|
      solutions = solutions.where(r["field"] + " = ?", r["value"])
    end

    filter_rules.select {|f| f["op"] == "contains" }.each do |r|
      solutions = solutions.where(r["field"] + " ilike ?", "%" + r["value"] + "%")
    end

    filter_rules.select {|f| f["op"] == "in" }.each do |r|
      solutions = solutions.where(r["field"] + " in (?)", r["value"].split(",") )
    end

  end
  @solutions = solutions.to_json(:include => [:solution_status_info])

end

post '/link/task_task' do
  target = JSON.parse(request.body.read)

  taskSvc = TaskSvc.new()
  taskSvc.link(target["taskCdA"], target["taskCdB"], target["relType"])

  {success: true, message: "Link success.", data: target}.to_json
end

post '/unlink/task_task' do
  target = JSON.parse(request.body.read)

  taskSvc = TaskSvc.new()
  taskSvc.unlink(target["taskCdA"], target["taskCdB"], target["relType"])

  {success: true, message: "Link success.", data: target}.to_json
end

get '/workplans' do
  # workplan = JSON.parse(TWorkplan.json(TWorkplan.all))
  # workplan.each do |r|
  #   r["id"] = r["work_plan_cd"]
  #   if(r["parent_cd"] != "") 
  #     r["parent"] = r["parent_cd"]
  #   end
  #   r["open"] = true
  # end
  # TWorkplan.json(workplan)
 
  con = ActiveRecord::Base.connection
  sql = "select pl.*,pl.work_plan_cd as id, pl.parent_cd as parent, case when pl.task_cd <> '' then ts.name else pl.name end as text from t_workplan pl left join t_task ts on pl.task_cd = ts.task_cd order by sort_order asc"
  p "*** sql ***"
  rows = con.select_all(sql).to_hash
  rows.to_json(:include => {:user_info => {}})

  # TWorkplan.all().to_json(include: :parent)
end

post '/workplans', provides: :json do
  # svc = TaskSvc.new()

  p "*** UPDATING ***"

  target = JSON.parse(request.body.read)

  if target["work_plan_cd"] != nil
    workplan = TWorkplan.find(target["work_plan_cd"])
  else
    workplan = TWorkplan.new()
    work_plan_cd = ActiveRecord::Base.connection.select_value(
        ActiveRecord::Base.send(
          :sanitize_sql_array,
          [ 'select sp_numbering(:numbering_type, :parent_cd)', 
            numbering_type: 'WP',
            parent_cd: ""]))
    p work_plan_cd
    workplan.work_plan_cd = work_plan_cd
  end

  workplan.task_cd = target["task_cd"]
  workplan.start_date = target["start_date"]
  workplan.end_date = target["end_date"]
  workplan.progress = target["progress"].to_f()
  workplan.user_cd = target["user_cd"]
  workplan.name = target["name"]
  workplan.parent_cd = target["parent_cd"]
  if target["work_plan_cd"] != nil
    workplan.sort_order = target["sort_order"]
  end
  workplan.work_type = target["work_type"]

  p workplan

  workplan.save()

  # if (target["solution_cd"] == nil) || (target["solution_cd"] == "")
  #   return {success: false, message: "Solution is not designated.", data: target}.to_json
  # end

  # p target
  # task = TTask.where(task_cd: target["task_cd"])

  # if(task.length == 0) 
  #   task = TTask.new()

  #   task["task_cd"] = svc.fetch_new_cd(target["solution_cd"])
  #   task["created"] = Time.now
  #   task["updated"] = Time.now
  #   task["created_by"] = ""
  #   task["updated_by"] = ""
  # else
  #   task = task[0]
  # end


  # task["solution_cd"] = target["solution_cd"]
  # task["task_type"] = target["task_type"]
  # task["name"] = target["name"]
  # task["status_type"] = target["status_type"]
  # task["priority_type"] = target["priority_type"]
  # task["description"] = target["description"]
  # task["parent_cd"] = (target["parent_cd"] != nil)? target["parent_cd"] : ""
  # task["root_parent_cd"] = ""
  # task["path"] = ""

  # task.save()
  # if(task.parent_cd != "")
  #   svc.link(task.task_cd, task.parent_cd, "TR02PR")
  # else
  #   svc.set_parent_root(task.task_cd)
  # end

  # {success: true, message: "Register success", data: task}.to_json
  target.to_json()
end

delete '/workplans/:cd' do
  TWorkplan.destroy(params[:cd])
  {success: true, message: "Register success", data: {}}.to_json
end
