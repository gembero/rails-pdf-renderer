class RailsPdfRenderer
  module ActionControllerHelper
    def self.prepended(base)
      # Protect from trying to augment modules that appear
      # as the result of adding other gems.
      return if base != ActionController::Base
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

      render_opts = {
        :template => options[:template],
        :layout => options[:layout],
        :formats => options[:formats],
        :handlers => options[:handlers],
        :assigns => options[:assigns]
      }
      render_opts[:inline] = options[:inline] if options[:inline]
      render_opts[:locals] = options[:locals] if options[:locals]
      render_opts[:file] = options[:file] if options[:file]
      html_string = render_to_string(render_opts)
      pdf_from_server(html_string, options)
    end

    def make_and_send_pdf(pdf_name, options = {})
      options[:layout] ||= false
      options[:template] ||= File.join(controller_path, action_name)
      options[:disposition] ||= 'inline'
      if options[:show_as_html]
        render_opts = {
          :template => options[:template],
          :layout => options[:layout],
          :formats => options[:formats],
          :handlers => options[:handlers],
          :assigns => options[:assigns],
          :content_type => 'text/html'
        }
        render_opts[:inline] = options[:inline] if options[:inline]
        render_opts[:locals] = options[:locals] if options[:locals]
        render_opts[:file] = options[:file] if options[:file]
        render(render_opts)
      else
        pdf_content = make_pdf(options)
        File.open(options[:save_to_file], 'wb') { |file| file << pdf_content } if options[:save_to_file]
        send_data(pdf_content, :filename => pdf_name + '.pdf', :type => 'application/pdf', :disposition => options[:disposition]) unless options[:save_only]
      end
    end

    def pdf_from_server(html, options)
      payload = pdf_server_params(html, options)

      auth_key = RailsPdfRenderer.configuration.auth_key
      url = RailsPdfRenderer.configuration.url
      auth_key64 = Base64.strict_encode64(auth_key)

      raise "auth_key is not set, you need to set it for rails-pdf-renderer to work" if auth_key.blank?

      uri = URI(url)
      headers = { 'Content-Type': 'application/json', "Authorization": "Bearer #{auth_key64}" }
      response = Net::HTTP.post(uri, payload.to_json, headers)

      if response.kind_of? Net::HTTPSuccess
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
