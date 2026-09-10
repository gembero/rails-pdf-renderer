# frozen_string_literal: true

RSpec.describe RailsPdfRenderer::Config do
  around do |example|
    previous = RailsPdfRenderer.instance_variable_get(:@configuration)
    RailsPdfRenderer.instance_variable_set(:@configuration, nil)
    example.run
    RailsPdfRenderer.instance_variable_set(:@configuration, previous)
  end

  describe "defaults" do
    subject(:config) { described_class.new }

    it { expect(config.auth_key).to be_nil }
    it { expect(config.url).to be_nil }
    it { expect(config.basic_auth).to be(false) }
    it { expect(config.default_protocol).to eq("https") }
    it { expect(config.raise_on_missing_assets).to be(true) }
    it { expect(config.expect_gzipped_remote_assets).to be(false) }

    it "defaults every margin to zero" do
      expect(config.default_options).to eq(
        margin: {top: "0mm", bottom: "0mm", left: "0mm", right: "0mm"}
      )
    end
  end

  describe "RailsPdfRenderer.configuration" do
    it "memoizes a single instance" do
      expect(RailsPdfRenderer.configuration).to be(RailsPdfRenderer.configuration)
    end
  end

  describe "RailsPdfRenderer.configure" do
    it "yields the configuration so it can be mutated" do
      RailsPdfRenderer.configure do |config|
        config.auth_key = "secret"
        config.url = "https://pdf.example.com/render"
      end

      expect(RailsPdfRenderer.configuration.auth_key).to eq("secret")
      expect(RailsPdfRenderer.configuration.url).to eq("https://pdf.example.com/render")
    end

    it "does not leak instance overrides onto the class defaults" do
      RailsPdfRenderer.configure { |config| config.default_protocol = "http" }

      expect(described_class.default_protocol).to eq("https")
    end
  end
end
