shared_context "when sending heat pump data" do
  def notify_client_test_api_key
    "epcheatpumptest-c58430da-e28f-492a-869a-9db3a17d8193-3ba4f26b-8fa7-4d73-bf04-49e94c3e2438"
  end

  def notify_client
    Notifications::Client.new(notify_client_test_api_key)
  end

  def template_id
    "b46eb2e7-f7d3-4092-9865-76b57cc24922"
  end
end
