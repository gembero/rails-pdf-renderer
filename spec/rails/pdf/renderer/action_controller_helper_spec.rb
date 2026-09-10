# frozen_string_literal: true

require "action_controller"

# A stand-in for ActionController::Base. The helper is prepended the way the railtie does
# it in a real application, so `super` falls through to these stubs and every example can
# see the options the gem would have handed to ActionView.
class FakePdfController
  attr_reader :super_render_options, :super_render_to_string_options, :sent_data

  def render(options = {})
    @super_render_options = options
  end

  def render_to_string(options = {})
    @super_render_to_string_options = options
    "RENDERED-TEMPLATE"
  end

  def send_data(data, options = {})
    @sent_data = [data, options]
  end

  def controller_path
    "invoices"
  end

  def action_name
    "show"
  end

  prepend RailsPdfRenderer::ActionControllerHelper
end

RSpec.describe RailsPdfRenderer::ActionControllerHelper do
  subject(:controller) { FakePdfController.new }

  let(:pdf_bytes) { "%PDF-1.4 fake" }
  let(:pdf_server_payload) { {} }

  # Finished HTML that happens to contain ERB. If it is ever compiled as a template this
  # renders as "<p>2</p>", which is what the :html option exists to prevent.
  let(:html_containing_erb) { "<p><%= 1 + 1 %></p>" }

  around do |example|
    previous = RailsPdfRenderer.instance_variable_get(:@configuration)
    RailsPdfRenderer.instance_variable_set(:@configuration, nil)
    RailsPdfRenderer.configure do |config|
      config.auth_key = "test-auth-key"
      config.url = "https://pdf.example.com/render"
    end
    example.run
    RailsPdfRenderer.instance_variable_set(:@configuration, previous)
  end

  before do
    allow(Net::HTTP).to receive(:post) do |_uri, body, _headers|
      pdf_server_payload.replace(JSON.parse(body))
      Net::HTTPOK.new("1.1", "200", "OK").tap do |response|
        allow(response).to receive(:body).and_return(pdf_bytes)
      end
    end
  end

  describe "the :html option" do
    it "sends the HTML to the PDF service verbatim" do
      result = controller.render_to_string(pdf: true, html: html_containing_erb)

      expect(pdf_server_payload["html"]).to eq(html_containing_erb)
      expect(result).to eq(pdf_bytes)
    end

    it "never hands the HTML to ActionView, so no template handler can run" do
      controller.render_to_string(pdf: true, html: html_containing_erb)

      expect(controller.super_render_to_string_options).to be_nil
    end

    it "still forwards the PDF service options" do
      controller.render_to_string(pdf: true, html: "<p>hi</p>", footerTemplate: "<i>page</i>")

      expect(pdf_server_payload["footerTemplate"]).to eq("<i>page</i>")
      expect(pdf_server_payload["marginTop"]).to eq("0mm")
    end

    it "renders an empty document rather than falling back to the action's template" do
      controller.render_to_string(pdf: true, html: nil)

      expect(pdf_server_payload["html"]).to eq("")
      expect(controller.super_render_to_string_options).to be_nil
    end

    it "refuses to be combined with :inline" do
      expect {
        controller.render_to_string(pdf: true, html: "<p>hi</p>", inline: "<p>hi</p>")
      }.to raise_error(ArgumentError, /mutually exclusive/)
    end
  end

  describe "#render with a :pdf option" do
    it "sends the generated PDF as a file" do
      controller.render(pdf: "invoice", html: html_containing_erb)

      expect(pdf_server_payload["html"]).to eq(html_containing_erb)
      expect(controller.sent_data).to eq(
        [pdf_bytes, {filename: "invoice.pdf", type: "application/pdf", disposition: "inline"}]
      )
    end

    it "forwards :status to the response" do
      controller.render(pdf: "invoice", html: "<p>hi</p>", status: :unprocessable_entity)

      expect(controller.sent_data.last[:status]).to eq(:unprocessable_entity)
    end
  end

  describe "show_as_html" do
    it "renders :html as finished, unescaped HTML without a layout" do
      controller.render(pdf: "invoice", html: html_containing_erb, show_as_html: true, status: 201)

      expect(controller.super_render_options).to eq(
        html: html_containing_erb, layout: false, content_type: "text/html", status: 201
      )
      expect(controller.super_render_options[:html]).to be_html_safe
      expect(Net::HTTP).not_to have_received(:post)
    end

    it "still renders :inline through ActionView" do
      controller.render(pdf: "invoice", inline: "<p><%= @name %></p>", show_as_html: true)

      expect(controller.super_render_options).to include(
        inline: "<p><%= @name %></p>", content_type: "text/html", layout: false
      )
    end
  end

  describe "the :inline option" do
    it "still goes through ActionView, unchanged" do
      controller.render_to_string(pdf: true, inline: html_containing_erb, locals: {name: "Ada"})

      expect(controller.super_render_to_string_options).to eq(
        template: nil, layout: nil, formats: nil, handlers: nil, assigns: nil,
        inline: html_containing_erb, locals: {name: "Ada"}
      )
      expect(pdf_server_payload["html"]).to eq("RENDERED-TEMPLATE")
    end

    it "forwards :type so a non-ERB handler can be used" do
      controller.render_to_string(pdf: true, inline: html_containing_erb, type: :raw)

      expect(controller.super_render_to_string_options[:type]).to eq(:raw)
    end
  end
end
