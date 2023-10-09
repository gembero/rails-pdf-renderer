class RailsPdfRenderer
  class Error < StandardError
    attr_accessor :http_response

    def initialize(http_response)
      @http_response = http_response
    end

    def message
      "Got error when trying to fetch PDF from server. HTTP error #{@http_response.code} #{@http_response.message}"
    end
  end
end