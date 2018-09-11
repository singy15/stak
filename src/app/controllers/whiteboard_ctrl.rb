
get '/view/whiteboard' do
  if(params["whiteboard_cd"]) 
    @whiteboard_cd = params["whiteboard_cd"]
  else
    @whiteboard_cd = ConstDefaults::DEFAULT_WHITEBOARD_CD
  end

  if(@whiteboard_cd === ConstDefaults::DEFAULT_WHITEBOARD_CD)
    suffix = "GLOBAL" 
  else
    suffix = @whiteboard_cd
  end

  @view_title = "Whiteboard (beta) / " + suffix
  @view_subtitle = ""

  @view_content = erb :part_whiteboard
  erb :template
end

get '/view/whiteboard/editor' do
  if(params["whiteboard_cd"]) 
    @whiteboard_cd = params["whiteboard_cd"]
  else
    @whiteboard_cd = ConstDefaults::DEFAULT_WHITEBOARD_CD
  end
  erb :part_whiteboard_editor
end

get '/whiteboard/:cd' do
  task_svc = TaskSvc.new()
  task = task_svc.select_by_cd_no_json(params[:cd])
  if((task == nil) && (params[:cd] != ConstDefaults::DEFAULT_WHITEBOARD_CD)) 
    {success: false, message: "Task not exists", data: nil}.to_json
  else
    whiteboardSvc = WhiteboardSvc.new()
    {success: true, message: "", data: whiteboardSvc.select_insert_by_cd(params[:cd])}.to_json
  end
end

post '/whiteboard/:cd', provides: :json do
  svc = WhiteboardSvc.new()
  target = JSON.parse(request.body.read)
  svc.update_content(params[:cd], target["content"])

  {success: true, message: "Register success", data: ""}.to_json
end

get '/whiteboard/:cd/exist', provides: :json do
  svc = WhiteboardSvc.new()
  is_exist = svc.select_exist_by_cd(params[:cd])

  {success: true, message: "", data: is_exist}.to_json
end

