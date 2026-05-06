# frozen_string_literal: true

module PageStructuredData
  # Basic page metadata for any page
  class Page
    attr_reader :title, :description, :image, :extra_title, :breadcrumb, :page_type, :page_types, :canonical_url,
                :fallback_image, :base_app_name, :render_breadcrumb_json_ld

    def initialize(title:, description: nil, image: nil, # rubocop:disable Metrics/ParameterLists
                   extra_title: '', breadcrumb: nil, page_type: nil, page_types: nil, canonical_url: nil,
                   fallback_image: nil, base_app_name: nil, render_breadcrumb_json_ld: nil)
      @title = title
      @description = description
      @image = image
      @extra_title = extra_title
      @breadcrumb = breadcrumb
      @page_type = page_type
      @page_types = page_types
      @canonical_url = canonical_url
      @fallback_image = fallback_image
      @base_app_name = base_app_name
      @render_breadcrumb_json_ld = render_breadcrumb_json_ld
    end

    def title_with_hierarchies
      current_page = extra_title.present? ? [title, extra_title] : [title]
      current_page += breadcrumb.titles.reverse if breadcrumb.present?
      current_page
    end

    def page_title
      result = title_with_hierarchies.join(separator)
      if resolved_base_app_name.present?
        result += separator + resolved_base_app_name
      end
      result
    end

    def json_lds
      output = []
      output << breadcrumb_json_ld if (breadcrumb_json_ld = self.breadcrumb_json_ld).present?
      resolved_page_types.each { |resolved_page_type| output << resolved_page_type.json_ld }
      output.join
    end

    def resolved_image
      image || fallback_image
    end

    private

    def resolved_page_types
      Array.wrap(page_types.presence || page_type).compact
    end

    def breadcrumb_json_ld
      return if render_breadcrumb_json_ld == false
      return breadcrumb.json_ld(current_page_title: title) if breadcrumb.present?
      return unless render_breadcrumb_json_ld?

      Breadcrumbs.new.json_ld(current_page_title: title)
    end

    def render_breadcrumb_json_ld?
      return render_breadcrumb_json_ld unless render_breadcrumb_json_ld.nil?

      PageStructuredData.render_default_breadcrumb_json_ld
    end

    def resolved_base_app_name
      return base_app_name unless base_app_name.nil?

      PageStructuredData.base_app_name
    end

    def separator
      ' - '
    end
  end
end
