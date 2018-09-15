
# Requires
require 'sinatra'
require './const.rb'
require './db_setting.rb'
Dir[File.dirname(__FILE__) + '/entities/*.rb'].each {|file| require file }
require './services/base/base_svc.rb'
Dir[File.dirname(__FILE__) + '/services/*.rb'].each {|file| require file }
Dir[File.dirname(__FILE__) + '/controllers/*.rb'].each {|file| require file }

enable :sessions

configure :development do |c| 
  require 'sinatra/reloader' 
  c.also_reload "./const.rb" 
  c.also_reload "./base_svc.rb" 
  c.also_reload "./db_setting.rb"
  c.also_reload "./entities/*.rb"
  c.also_reload "./services/base/*.rb" 
  c.also_reload "./services/*.rb" 
  c.also_reload "./controllers/*.rb" 
end


get '/' do
  @view_title = "Welcome"
  @view_subtitle = "Welcome to Stak"
  @view_content = erb :part_top_content
  erb :template
end



