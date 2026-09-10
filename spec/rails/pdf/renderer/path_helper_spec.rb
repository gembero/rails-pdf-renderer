# frozen_string_literal: true

RSpec.describe RailsPdfRenderer::PathHelper do
  describe ".add_extension" do
    it "appends the extension when it is missing" do
      expect(described_class.add_extension("application", "css")).to eq("application.css")
    end

    it "leaves the filename alone when it already has the extension" do
      expect(described_class.add_extension("application.css", "css")).to eq("application.css")
    end

    it "recognises the extension in a multi-part filename" do
      expect(described_class.add_extension("application.min.css", "css")).to eq("application.min.css")
    end

    it "appends when only a different extension is present" do
      expect(described_class.add_extension("application.js", "css")).to eq("application.js.css")
    end

    it "accepts non-string filenames" do
      expect(described_class.add_extension(:application, "js")).to eq("application.js")
    end
  end
end
