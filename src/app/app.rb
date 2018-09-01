
# Requires
require 'sinatra'
require './const.rb'
# require './service/*.rb'
Dir[File.dirname(__FILE__) + '/service/*.rb'].each {|file| require file }
require './db_setting.rb'

configure :development do |c| 
  require 'sinatra/reloader' 
  c.also_reload "./const.rb" 
  c.also_reload "./service/*.rb" 
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
  @key_value_task_status_type = typeSvc.kv_task_status()
  @key_value_task_type = typeSvc.kv_task_type()
  @key_value_task_priority_type = typeSvc.kv_task_priority()
  @key_value_task_task_relation_type = typeSvc.kv_task_task_relation()
  @key_value_solution = typeSvc.kv_solution()

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
  # # workplan = JSON.parse(TWorkplan.json(TWorkplan.all))
  # # workplan.each do |r|
  # #   r["id"] = r["work_plan_cd"]
  # #   if(r["parent_cd"] != "") 
  # #     r["parent"] = r["parent_cd"]
  # #   end
  # #   r["open"] = true
  # # end
  # # TWorkplan.json(workplan)
 
  # con = ActiveRecord::Base.connection
  # # from t_workplan
  # # sql = ""
  # # sql += "select"
  # # sql += " pl.*,"
  # # sql += " pl.work_plan_cd as id,"
  # # sql += " pl.parent_cd as parent,"
  # # sql += " case when pl.task_cd <> '' then ts.name else pl.name end as text"
  # # sql += " from t_workplan pl"
  # # sql += " left join t_task ts"
  # # sql += " on pl.task_cd = ts.task_cd"
  # # sql += " order by sort_order asc"

  # # from t_task
  # sql = ""
  # sql += "select"
  # sql += " pl.*,"
  # sql += " task_cd as id,"
  # sql += " task_cd as work_plan_cd,"
  # sql += " parent_cd as parent,"
  # sql += " pl.name as text,"
  # sql += " pl.name as name,"
  # sql += " start_dt as start_date,"
  # sql += " end_dt as end_date,"
  # sql += " pl.sort_order as sort_order"
  # sql += " from t_task pl"
  # sql += " order by pl.sort_order asc"
  # p "*** sql ***"
  # rows = con.select_all(sql).to_hash
  # rows.to_json(:include => {:user_info => {}})

  # # TWorkplan.all().to_json(include: :parent)
  
  rows = select_workplans_by_task(true)
  rows.to_json(:include => {:user_info => {}})
end

get '/workplans/with_closed' do
  # # workplan = JSON.parse(TWorkplan.json(TWorkplan.all))
  # # workplan.each do |r|
  # #   r["id"] = r["work_plan_cd"]
  # #   if(r["parent_cd"] != "") 
  # #     r["parent"] = r["parent_cd"]
  # #   end
  # #   r["open"] = true
  # # end
  # # TWorkplan.json(workplan)
 
  # con = ActiveRecord::Base.connection
  # # from t_workplan
  # # sql = ""
  # # sql += "select"
  # # sql += " pl.*,"
  # # sql += " pl.work_plan_cd as id,"
  # # sql += " pl.parent_cd as parent,"
  # # sql += " case when pl.task_cd <> '' then ts.name else pl.name end as text"
  # # sql += " from t_workplan pl"
  # # sql += " left join t_task ts"
  # # sql += " on pl.task_cd = ts.task_cd"
  # # sql += " order by sort_order asc"

  # # from t_task
  # sql = ""
  # sql += "select"
  # sql += " pl.*,"
  # sql += " task_cd as id,"
  # sql += " task_cd as work_plan_cd,"
  # sql += " parent_cd as parent,"
  # sql += " pl.name as text,"
  # sql += " pl.name as name,"
  # sql += " start_dt as start_date,"
  # sql += " end_dt as end_date,"
  # sql += " pl.sort_order as sort_order"
  # sql += " from t_task pl"
  # sql += " order by pl.sort_order asc"
  # p "*** sql ***"
  # rows = con.select_all(sql).to_hash
  # rows.to_json(:include => {:user_info => {}})

  # # TWorkplan.all().to_json(include: :parent)
  
  rows = select_workplans_by_task(false)
  rows.to_json(:include => {:user_info => {}})
end


post '/workplans', provides: :json do
  #  # svc = TaskSvc.new()

  #  p "*** UPDATING ***"

  #  target = JSON.parse(request.body.read)

  #  ## workplan version
  #  # if target["work_plan_cd"] != nil
  #  #   workplan = TWorkplan.find(target["work_plan_cd"])
  #  # else
  #  #   workplan = TWorkplan.new()
  #  #   work_plan_cd = ActiveRecord::Base.connection.select_value(
  #  #       ActiveRecord::Base.send(
  #  #         :sanitize_sql_array,
  #  #         [ 'select sp_numbering(:numbering_type, :parent_cd)', 
  #  #           numbering_type: 'WP',
  #  #           parent_cd: ""]))
  #  #   p work_plan_cd
  #  #   workplan.work_plan_cd = work_plan_cd
  #  # end

  #  ## task version
  #  if target["work_plan_cd"] != nil
  #    # workplan = TWorkplan.find(target["work_plan_cd"])
  #    workplan = TTask.find(target["work_plan_cd"])
  #  else
  #    svc = TaskSvc.new()
  #    workplan = TTask.new()
  #    workplan["task_cd"] = svc.fetch_new_cd("00")
  #    workplan["solution_cd"] = "00"
  #    workplan["task_type"] = "TS01NW"
  #    workplan["status_type"] = "TT01TS"
  #    workplan["description"] = ""
  #    workplan["parent_cd"] = ""
  #    workplan["root_parent_cd"] = workplan["task_cd"]
  #    workplan["user_cd"] = "001"
  #    workplan["path"] = ""
  #    workplan["created"] = Time.now
  #    workplan["updated"] = Time.now
  #    workplan["created_by"] = ""
  #    workplan["updated_by"] = ""

  #    p workplan["task_cd"]
  #  end

  #  ## workplan version
  #  # workplan.task_cd = target["task_cd"]
  #  # workplan.start_date = target["start_date"]
  #  # workplan.end_date = target["end_date"]
  #  # workplan.progress = target["progress"].to_f()
  #  # workplan.user_cd = target["user_cd"]
  #  # workplan.name = target["name"]
  #  # workplan.parent_cd = target["parent_cd"]
  #  # if target["work_plan_cd"] != nil
  #  #   workplan.sort_order = target["sort_order"]
  #  # end
  #  # workplan.work_type = target["work_type"]

  #  ## task version
  #  # workplan.task_cd = target["task_cd"]
  #  workplan.start_dt = target["start_date"]
  #  workplan.end_dt = target["end_date"]
  #  # workplan.progress = target["progress"].to_f()
  #  # workplan.user_cd = target["user_cd"]
  #  workplan.name = target["name"]
  #  # workplan.parent_cd = target["parent_cd"]
  #  if target["work_plan_cd"] != nil
  #    workplan.sort_order = target["sort_order"]
  #  end
  #  # workplan.work_type = target["work_type"]

  #  p workplan

  #  workplan.save()

  #  # if (target["solution_cd"] == nil) || (target["solution_cd"] == "")
  #  #   return {success: false, message: "Solution is not designated.", data: target}.to_json
  #  # end

  #  # p target
  #  # task = TTask.where(task_cd: target["task_cd"])

  #  # if(task.length == 0) 
  #  #   task = TTask.new()

  #  #   task["task_cd"] = svc.fetch_new_cd(target["solution_cd"])
  #  #   task["created"] = Time.now
  #  #   task["updated"] = Time.now
  #  #   task["created_by"] = ""
  #  #   task["updated_by"] = ""
  #  # else
  #  #   task = task[0]
  #  # end


  #  # task["solution_cd"] = target["solution_cd"]
  #  # task["task_type"] = target["task_type"]
  #  # task["name"] = target["name"]
  #  # task["status_type"] = target["status_type"]
  #  # task["priority_type"] = target["priority_type"]
  #  # task["description"] = target["description"]
  #  # task["parent_cd"] = (target["parent_cd"] != nil)? target["parent_cd"] : ""
  #  # task["root_parent_cd"] = ""
  #  # task["path"] = ""

  #  # task.save()
  #  # if(task.parent_cd != "")
  #  #   svc.link(task.task_cd, task.parent_cd, "TR02PR")
  #  # else
  #  #   svc.set_parent_root(task.task_cd)
  #  # end

  #  # {success: true, message: "Register success", data: task}.to_json
  #  target.to_json()











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
  # TWorkplan.destroy(params[:cd])
  TTask.destroy(params[:cd])
  {success: true, message: "Register success", data: {}}.to_json
end

