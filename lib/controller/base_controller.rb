require "sinatra"

module Controller
  class BaseController < Sinatra::Base
    def initialize(app = nil, **_kwargs)
      super
    end
  end
end
