require "active_record"
require "active_support"
require "zeitwerk"

loader = Zeitwerk::Loader.new
loader.push_dir("#{__dir__}/lib")
loader.setup

# DATABASE_URL is defined by default on GOV PaaS if there is a bound PostgreSQL database
ActiveRecord::Base.establish_connection(ENV["DATABASE_URL"])
