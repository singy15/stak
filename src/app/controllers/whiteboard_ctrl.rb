
get '/view/whiteboard' do
  if(params["whiteboard_cd"]) 
    @whiteboard_cd = params["whiteboard_cd"]
  else
    @whiteboard_cd = "00-0000"
  end

  @view_title = "Whiteboard (pre-alpha)"
  @view_subtitle = ""

  @view_content = erb :part_whiteboard
  erb :template
end

get '/view/whiteboard/sub' do
  if(params["whiteboard_cd"]) 
    @whiteboard_cd = params["whiteboard_cd"]
  else
    @whiteboard_cd = "00-0000"
  end
  erb :layouteditor
end

get '/view/whiteboard/editor' do
  if(params["whiteboard_cd"]) 
    @whiteboard_cd = params["whiteboard_cd"]
  else
    @whiteboard_cd = "00-0000"
  end
  erb :part_whiteboard_editor
end

get '/whiteboard/:cd' do
  task_svc = TaskSvc.new()
  task = task_svc.select_by_cd_no_json(params[:cd])
  if((task == nil) && (params[:cd] != "00-0000")) 
    {success: false, message: "Task not exists", data: nil}.to_json
  else
    whiteboardSvc = WhiteboardSvc.new()
    # TWhiteboard.json(whiteboardSvc.select_by_cd(params[:cd]))
    {success: true, message: "", data: whiteboardSvc.select_insert_by_cd(params[:cd])}.to_json
  end
end

post '/whiteboard/:cd', provides: :json do
  svc = WhiteboardSvc.new()
  target = JSON.parse(request.body.read)
  svc.update_content(params[:cd], target["content"])

  {success: true, message: "Register success", data: ""}.to_json
end

