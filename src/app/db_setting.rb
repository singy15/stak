
require 'json'
require 'pg'
require 'active_record'

ActiveRecord::Base.logger = Logger.new("log/sql.log", 'daily')

ActiveRecord::Base.establish_connection(
    adapter: 'postgresql',  
    encoding: 'unicode', 
    database: 'stak', 
    pool: 20, 
    username: 'stakuser', 
    password: 'stakuserpasswd',
    reconnect: true
)

