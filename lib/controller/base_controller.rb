require "sinatra"
require "epb-auth-tools"

module Controller
  class BaseController < Sinatra::Base
    def initialize(app = nil, **_kwargs)
      super
    end

    set(:auth_token_has_all) do |*scopes|
      condition do
        token = Auth::Sinatra::Conditional.process_request env
        unless token.scopes?(scopes)
          forbidden(
            "UNAUTHORISED",
            "You are not authorised to perform this request",
          )
        end
        env[:auth_token] = token
      rescue Auth::Errors::Error => e
        content_type :json
        halt 401, { errors: [{ code: e }] }.to_json
      end
    end
  end
end
