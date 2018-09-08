
get '/view/whiteboard' do
  @view_title = "Whiteboard (pre-alpha)"
  @view_subtitle = ""

  @view_content = erb :part_whiteboard
  erb :template
end

get '/view/whiteboard/sub' do
  erb :layouteditor
end

get '/view/whiteboard/editor' do
  erb :part_whiteboard_editor
end

get '/whiteboard/default' do
  whiteboardSvc = WhiteboardSvc.new()
  TWhiteboard.json(whiteboardSvc.select_first())
end

post '/whiteboard/default', provides: :json do
  svc = WhiteboardSvc.new()
  target = JSON.parse(request.body.read)
  svc.update_first_content(target["content"])

  {success: true, message: "Register success", data: ""}.to_json
end

