require "webmock"

class HttpStub
  OAUTH_TOKEN =
    "eyJhbGciOiJIUzI1NiJ9.eyJleHAiOjE1OTc3NzU5NDAsImlhdCI6MTU5Nzc3MjM0MCwiaXNzIjoidGVzdC1pc3N1ZXIiLCJzdWIiOiJ0ZXN0LXN1YiJ9.RyXrSxCzEgnepsYEft8YP5W6tKUAlcVnS_83FGDMy3Y"
      .freeze

  def self.call_api(endpoint)
    WebMock.stub_request(
      :get,
      "http://test-register/api/#{endpoint}",
    )
        .with(
          headers: {
            "Accept" => "*/*",
            "Accept-Encoding" => "gzip;q=1.0,deflate;q=0.6,identity;q=0.3",
            "User-Agent" => "Ruby",
          },
        ).to_return status: 200,
                    body: "",
                    headers: {}
  end

  def self.failed_lodgement(
    error = nil,
    error_response = nil,
    assessor_created: false
  )
    WebMock.enable!

    stub =
      WebMock.stub_request(
        :post,
        "http://test-register/api/assessments?migrated&assessor_created=#{assessor_created}",
      )

    if error
      stub.to_raise error
    else
      response = {
        errors: [
          {
            code: "INVALID_REQUEST",
            title:
              "4:0: ERROR: Element '{https://epbr.digital.communities.gov.uk/xsd/cepc}Reports': No matching global declaration available for the validation root.",
          },
        ],
      }

      response = error_response unless error_response.nil?

      # to_return(body: lambda { |request| request.body })
      stub.to_return status: 400,
                     body: JSON.generate(response),
                     headers: {
                       "Content-Type" => "application/json",
                     }
    end
  end

  def self.successful_status_update(assessment_id, status)
    WebMock.enable!

    WebMock
      .stub_request(
        :post,
        "http://test-register/api/assessments/#{assessment_id}/status",
      )
      .with(
        body: JSON.generate(status: status),
        headers: {
          "Authorization" => "Bearer #{OAUTH_TOKEN}",
        },
      ).to_return status: 200,
                  body: JSON.generate(status: status),
                  headers: {
                    "Content-Type" => "application/json",
                  }
  end

  def self.unsuccessful_status_update(assessment_id, status)
    WebMock.enable!

    WebMock
      .stub_request(
        :post,
        "http://test-register/api/assessments/#{assessment_id}/status",
      )
      .with(
        body: JSON.generate(status: status),
        headers: {
          "Authorization" => "Bearer #{OAUTH_TOKEN}",
        },
      ).to_return status: 404,
                  body:
                      JSON.generate(
                        {
                          errors: [
                            { code: "NOT_FOUND", title: "Assessment not found" },
                          ],
                        },
                      ),
                  headers: {
                    "Content-Type" => "application/json",
                  }
  end

  def self.successful_token
    WebMock.enable!

    WebMock.stub_request(
      :post,
      "http://test-auth/oauth/token",
    ).to_return status: 200,
                body:
                    JSON
                      .generate(
                        access_token:
                          OAUTH_TOKEN,
                        expires_in:
                          3_600,
                        token_type:
                          "bearer",
                      ),
                headers: {
                  "Content-Type" =>
                    "application/json",
                }
  end

  def self.failed_token
    WebMock.enable!

    WebMock.stub_request(
      :post,
      "http://test-auth/oauth/token",
    ).to_return status: 401,
                body:
                    JSON
                      .generate(
                        code:
                          "NOT_AUTHENTICATED",
                        message:
                          "Boundary::NotAuthenticatedError",
                      ),
                headers: {
                  "Content-Type" =>
                    "application/json",
                }
  end
end
