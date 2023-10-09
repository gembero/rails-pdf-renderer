# frozen_string_literal: true

require_relative "renderer/version"
require_relative "renderer/config"
require_relative "renderer/error"
require_relative "renderer/railtie"

class RailsPdfRenderer
  def self.configuration
    @configuration ||= Config.new
  end

  def self.configure
    yield configuration
  end
end
