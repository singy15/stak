
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

delete '/solutions/:cd' do
  @task = TSolution.destroy(params[:cd])
  {success: true, message: "Delete success", data: nil}.to_json
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
