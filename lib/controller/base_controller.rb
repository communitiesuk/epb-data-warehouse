# frozen_string_literal: true

require "sinatra"
require "sinatra/activerecord"
require "epb-auth-tools"

module Controller
  class BaseController < Sinatra::Base
    configure :development do
      require "sinatra/reloader"
      register Sinatra::Reloader
      also_reload "lib/**/*.rb"
      set :host_authorization, { permitted_hosts: [] }
      set :show_exceptions, false
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

    set(:has_bearer_token) do |_|
      condition do
        auth_header = env["HTTP_AUTHORIZATION"]

        raise Errors::MissingBearerToken if auth_header.nil? || !auth_header.include?("Bearer")

        bearer_token = auth_header.sub("Bearer ", "")
        authenticated = Container.authenticate_user_use_case.execute(bearer_token)
        raise Errors::MissingBearerToken unless authenticated
      rescue Errors::MissingBearerToken
        content_type :json
        halt 403, { errors: [{ code: "UNAUTHORISED", title: "You are not authenticated" }] }.to_json
      end
    end

    error do |exception|
      if settings.environment == :development
        json_response(error_details(exception), 500)
      else
        status 500
        "SERVER ERROR"
      end
    end

  private

    def json_api_response(
      code: 200,
      data: {},
      pagination: {},
      camel_case: true
    )
      response_data = { data: }
      response_data[:pagination] = pagination unless pagination.empty?
      json_response(response_data, code, camel_case:)
    end

    def json_response(hash, code = 200, camel_case: true)
      ActiveRecord::Base.connection_handler.clear_active_connections!(:all)

      content_type :json
      status code

      if camel_case
        Helper::JsonHelper.convert_to_json(hash)
      else
        hash.to_json
      end
    end

    def params_body(schema)
      Helper::JsonHelper.convert_to_ruby_hash(params.to_json, schema:)
    end

    def report_to_sentry(exception)
      Sentry.capture_exception(exception) if defined?(Sentry)
    end

    def error_details(exception)
      {
        type: exception.class.name,
        message: exception.message,
        backtrace: exception&.backtrace&.select { it.start_with?(File.expand_path("..", __dir__)) },
        cause: exception.cause && error_details(exception.cause),
      }.compact
    end
  end
end
