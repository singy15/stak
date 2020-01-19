
get '/view/solutions' do
  authenticate!
  @view_title = "Solutions"
  @view_subtitle = ""
  @solutions = TSolution.all.to_json
  @status_types = CType.where(type_category: "SS").order("sort_order").to_json
  typeSvc = TypeSvc.new()
  @key_value_solution_status_type = typeSvc.kv_solution_status_type()
  @view_content = erb :part_solution_list
  @view_content_bottom = erb :part_solution_bottom
  erb :template
end

delete '/solutions/:cd' do
  authenticate!
  svc = SolutionSvc.new()
  rslt = svc.delete_by_cd(params[:cd])
  ControllerUtil.response(rslt.success, rslt.msg, rslt.data)
end

put '/solutions', provides: :json do
  authenticate!
  target = JSON.parse(request.body.read)
  svc = SolutionSvc.new()
  rslt = svc.upsert(target)
  ControllerUtil.response(rslt.success, rslt.msg, rslt.data)
end

get '/solutions' do
  authenticate!
  svc = SolutionSvc.new()
  rslt = svc.select_by_condition(params)
  ControllerUtil.response_grid(rslt.total, JSON.parse(rslt.rows.to_json(:include => [:solution_status_info])))
end
