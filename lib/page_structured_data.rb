require "page_structured_data/version"
require "page_structured_data/engine"

module PageStructuredData
  class << self
    attr_accessor :base_app_name
    attr_writer :render_default_breadcrumb_json_ld

    def config
      yield self
    end

    def render_default_breadcrumb_json_ld
      return true if @render_default_breadcrumb_json_ld.nil?

      @render_default_breadcrumb_json_ld
    end
  end
end
