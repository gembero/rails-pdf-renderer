# frozen_string_literal: true

RSpec.describe RailsPdfRenderer::Error do
  let(:response) { double(code: "502", message: "Bad Gateway") }

  it "is a StandardError" do
    expect(described_class.new(response)).to be_a(StandardError)
  end

  it "exposes the http response" do
    expect(described_class.new(response).http_response).to be(response)
  end

  it "includes the response status in the message" do
    expect(described_class.new(response).message)
      .to eq("Got error when trying to fetch PDF from server. HTTP error 502 Bad Gateway")
  end
end
