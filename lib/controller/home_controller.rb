module Controller
  class HomeController < Controller::BaseController
    get "/",
        auth_token_has_all: %w[warehouse:test] do
      "Hello world!"
    end
  end
end
