
get '/view/whiteboard' do
  @view_title = "Whiteboard (pre-alpha)"
  @view_subtitle = ""

  @view_content = erb :part_whiteboard
  erb :template
end

