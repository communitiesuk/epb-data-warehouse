module Helper
  module Response
    def self.ensure_good(&block)
      begin
        response = yield block
      rescue Auth::Errors::NetworkConnectionFailed, Faraday::TimeoutError
        # try once again on a possibly transient network error
        begin
          response = yield block
        rescue StandardError => e
          raise Errors::ConnectionApiError,
                sprintf(
                  "Connection to API failed, even after retry. Message from %s: \"%s\"",
                  e.class,
                  e.message,
                )
        end
      end

      ensure_is_response response

      if response.status == 401
        raise Errors::ApiAuthorizationError,
              sprintf("Authorization issue with internal API. Response body: \"%s\"", response.body)
      end

      if [502, 504].include?(response.status)
        raise Errors::ConnectionApiError, "Gateway error when making request to the API"
      end

      unless response.status < 400 ||
          JSON.parse(response.body, symbolize_names: true)[:errors]
        raise Errors::MalformedErrorResponseError,
              sprintf(
                "Internal API response of status code %s had no errors node. Response body: \"%s\"",
                response.status,
                response.body,
              )
      end

      response
    end

    def self.check_valid_json(content)
      JSON.parse(content)
      true
    rescue JSON::ParserError
      false
    end

    def self.ensure_is_response(response)
      unless %i[status body].all? { |method| response.respond_to? method }
        raise Errors::ResponseNotPresentError,
              sprintf("Response object was expected from call on internal HTTP client, object of type %s returned instead.", response.class)
      end
    end
  end
end
