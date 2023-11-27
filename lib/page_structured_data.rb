require "page_structured_data/version"
require "page_structured_data/engine"

module PageStructuredData
  class << self
    attr_accessor :default_image_url, :base_app_name

    def config
      yield self
    end
  end
end
