require "base64"
require "json"
require "net/http"
require "active_support/core_ext/object/blank"
require "active_support/core_ext/string/output_safety"

class RailsPdfRenderer
  module ActionControllerHelper
    def self.prepended(base)
      # Protect from trying to augment modules that appear
      # as the result of adding other gems.
      nil if base != ActionController::Base
    end

    def render(*args)
      options = args.first
      if options.is_a?(Hash) && options.key?(:pdf)
        make_and_send_pdf(options.delete(:pdf), RailsPdfRenderer.configuration.default_options.merge(options))
      else
        super
      end
    end

    def render_to_string(*args)
      options = args.first
      if options.is_a?(Hash) && options.key?(:pdf)
        make_pdf(RailsPdfRenderer.configuration.default_options.merge(options))
      else
        super
      end
    end

    private

    def make_pdf(options = {})
      options.delete :pdf # We dont use the filename when rendering to string

      return pdf_from_server(raw_html(options), options) if options.key?(:html)

      pdf_from_server(render_to_string(view_render_options(options)), options)
    end

    def make_and_send_pdf(pdf_name, options = {})
      options[:layout] ||= false
      options[:template] ||= File.join(controller_path, action_name)
      options[:disposition] ||= "inline"
      if options[:show_as_html]
        render_opts = if options.key?(:html)
          {html: raw_html(options).html_safe, layout: false, content_type: "text/html"}
        else
          view_render_options(options).merge(content_type: "text/html")
        end
        render_opts[:status] = options[:status] if options[:status]
        render(render_opts)
      else
        pdf_content = make_pdf(options)
        File.open(options[:save_to_file], "wb") { |file| file << pdf_content } if options[:save_to_file]
        unless options[:save_only]
          send_opts = {filename: pdf_name + ".pdf", type: "application/pdf", disposition: options[:disposition]}
          send_opts[:status] = options[:status] if options[:status]
          send_data(pdf_content, send_opts)
        end
      end
    end

    # Already-rendered HTML supplied by the caller through the :html option. Unlike
    # :inline it is never compiled as a template, so `<%= %>` in the content cannot
    # execute as Ruby on the server.
    def raw_html(options)
      if options.key?(:inline)
        raise ArgumentError, "rails-pdf-renderer: :html and :inline are mutually exclusive. " \
          ":html is finished HTML, :inline is an ERB template."
      end
      options[:html].to_s
    end

    # Options for rendering through ActionView. Everything here goes through a template
    # handler - :inline defaults to ERB unless :type says otherwise.
    def view_render_options(options)
      render_opts = {
        template: options[:template],
        layout: options[:layout],
        formats: options[:formats],
        handlers: options[:handlers],
        assigns: options[:assigns]
      }
      render_opts[:inline] = options[:inline] if options[:inline]
      render_opts[:locals] = options[:locals] if options[:locals]
      render_opts[:file] = options[:file] if options[:file]
      render_opts[:type] = options[:type] if options[:type]
      render_opts
    end

    def pdf_from_server(html, options)
      payload = pdf_server_params(html, options)

      auth_key = RailsPdfRenderer.configuration.auth_key
      url = RailsPdfRenderer.configuration.url
      auth_key64 = Base64.strict_encode64(auth_key)

      raise "auth_key is not set, you need to set it for rails-pdf-renderer to work" if auth_key.blank?

      uri = URI(url)
      headers = {"Content-Type": "application/json", Authorization: "Bearer #{auth_key64}"}
      response = Net::HTTP.post(uri, payload.to_json, headers)

      if response.is_a? Net::HTTPSuccess
        response.body
      else
        raise RailsPdfRenderer::Error.new(response)
      end
    end

    def pdf_server_params(html, options = {})
      request_params = {}
      request_params[:html] = html
      request_params[:orientation] = options[:orientation] if options.key?(:orientation)
      request_params[:pageSize] = options[:pageSize] if options.key?(:pageSize)
      request_params[:zoom] = options[:zoom] if options.key?(:zoom)
      request_params[:height] = options[:height] if options.key?(:height)
      request_params[:width] = options[:width] if options.key?(:width)
      request_params[:footerTemplate] = options[:footerTemplate] if options.key?(:footerTemplate)
      request_params[:marginTop] = options[:margin][:top]
      request_params[:marginBottom] = options[:margin][:bottom]
      request_params[:marginLeft] = options[:margin][:left]
      request_params[:marginRight] = options[:margin][:right]
      request_params
    end
  end
end
