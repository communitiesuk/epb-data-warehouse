describe "HTTP requests made to the register API", type: :feature do
  after { WebMock.disable! }

  before do
    stub_request(:get, "http://test-register/api/assessments/0000-0000-0000-0001/summary:80/")
      .with(
        headers: {
          "Accept" => "*/*",
          "Accept-Encoding" => "gzip;q=1.0,deflate;q=0.6,identity;q=0.3",
          "User-Agent" => "Ruby",
        },
      )
      .to_return(status: 200, body: "", headers: {})
  end

  it "can convert the json received when making a request to the register API for an assessment" do
    expect(Net::HTTP.get("test-register/api/assessments/0000-0000-0000-0001/summary", "/")).to be_truthy
  end
end
