class RailsPdfRenderer
  class Config
    class_attribute :auth_key, instance_accessor: true
    class_attribute :url, instance_accessor: true
    class_attribute :basic_auth, instance_accessor: true, default: false
    class_attribute :default_protocol, instance_accessor: true, default: "https"
    class_attribute :raise_on_missing_assets, instance_accessor: true, default: true
    class_attribute :expect_gzipped_remote_assets, instance_accessor: true, default: false
    class_attribute :default_options, instance_accessor: true, default: {
      margin: {
        top: "0mm",
        bottom: "0mm",
        left: "0mm",
        right: "0mm"
      }
    }
  end
end