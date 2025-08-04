require "sinatra"
require "sinatra/activerecord"
require "epb-auth-tools"

module Controller
  class BaseController < Sinatra::Base
    def initialize(app = nil, **_kwargs)
      super
      @json_helper = Helper::JsonHelper.new
    end

    configure :development do
      require "sinatra/reloader"
      register Sinatra::Reloader
      also_reload "lib/**/*.rb"
      set :host_authorization, { permitted_hosts: [] }
    end

    set(:auth_token_has_all) do |*scopes|
      condition do
        token = Auth::Sinatra::Conditional.process_request env
        unless token.scopes?(scopes)
          content_type :json
          halt 403, { errors: [{ code: "UNAUTHORISED", title: "You are not authorised to perform this request" }] }.to_json
        end
        env[:auth_token] = token
      rescue Auth::Errors::Error => e
        content_type :json
        halt 401, { errors: [{ code: e }] }.to_json
      end
    end

    def json_api_response(
      code: 200,
      data: {},
      meta: {},
      pagination_hash: {},
      burrow_key: false,
      data_key: :data
    )
      if burrow_key
        data, meta = meta, data
        data[burrow_key] = meta.delete(data_key)
      end

      response_data = { data:, meta: }
      response_data[:pagination] = pagination_hash unless pagination_hash.empty?
      json_response(response_data, code)
    end

    def json_response(object, code = 200)
      content_type :json
      status code

      ActiveRecord::Base.connection_handler.clear_active_connections!(:all)

      convert_to_json(object)
    end

    def convert_to_json(hash)
      JSON.parse(hash.to_json).deep_transform_keys { |k|
        k.camelize(:lower)
      }.to_json
    end

    def params_body(schema)
      @json_helper.convert_to_ruby_hash(params.to_json, schema:)
    end
  end
end
