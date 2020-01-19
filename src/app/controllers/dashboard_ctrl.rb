
get '/view/dashboard' do
  authenticate!
  @view_title = "Dashboard"
  @view_subtitle = ""
  erb :template
end
