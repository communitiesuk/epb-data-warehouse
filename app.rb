require "pg" # postgresql
require "erb"
require "yaml"
require "active_record"
require "sinatra/activerecord"



pp ActiveRecord::Base.connection.exec_query("SELECT * FROM assessment_look_ups")