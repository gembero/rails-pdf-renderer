class RailsPdfRenderer
  class Config
    include ActiveSupport::Configurable

    config_accessor :auth_key
    config_accessor :url
    config_accessor(:basic_auth) { false }
    config_accessor(:default_protocol) { "https" }
    config_accessor(:raise_on_missing_assets) { true }
    config_accessor(:expect_gzipped_remote_assets) { false }


    config_accessor(:default_options) do  {
      margin: {
        top: "0mm",
        bottom: "0mm",
        left: "0mm",
        right: "0mm"
      }
    }
    end
  end
end