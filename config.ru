require "active_support"
require "active_support/core_ext"
require "sentry-ruby"
require "zeitwerk"

loader = Zeitwerk::Loader.new
loader.push_dir("#{__dir__}/lib/")
loader.setup

run DataWarehouseApiService
