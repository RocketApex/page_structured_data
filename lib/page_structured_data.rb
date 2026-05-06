require "page_structured_data/version"
require "page_structured_data/engine"
require_relative "../app/src/page_structured_data/anchors"
require_relative "../app/src/page_structured_data/breadcrumbs"
require_relative "../app/src/page_structured_data/page_types/interaction_statistic"
require_relative "../app/src/page_structured_data/page_types/article"
require_relative "../app/src/page_structured_data/page_types/blog_posting"
require_relative "../app/src/page_structured_data/page_types/news_article"
require_relative "../app/src/page_structured_data/page_types/discussion_forum_posting"
require_relative "../app/src/page_structured_data/page_types/organization"
require_relative "../app/src/page_structured_data/page_types/web_site"
require_relative "../app/src/page_structured_data/page"

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
