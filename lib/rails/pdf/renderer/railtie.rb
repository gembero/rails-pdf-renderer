require_relative 'action_controller_helper'
require_relative 'action_view_helper'

class RailsPdfRenderer
  if defined?(Rails.env)
    class RailsPdfRendererRailtie < Rails::Railtie
      initializer 'rails-pdf-renderer.register' do |_app|
        ActiveSupport.on_load(:action_controller) { ActionController::Base.send :prepend, RailsPdfRenderer::ActionControllerHelper }
        ActiveSupport.on_load(:action_view) { include RailsPdfRenderer::ActionViewHelper }
      end
    end

    Mime::Type.register('application/pdf', :pdf) if Mime::Type.lookup_by_extension(:pdf).nil?
  end
end
