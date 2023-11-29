# frozen_string_literal: true

module PageStructuredData
  # Basic page metadata for any page
  class Page
    attr_reader :title, :description, :image, :extra_title, :breadcrumb, :page_type

    def initialize(title:, description: nil, image: nil, # rubocop:disable Metrics/ParameterLists
                   extra_title: '', breadcrumb: nil, page_type: nil)
      @title = title
      @description = description
      @image = image
      @extra_title = extra_title
      @breadcrumb = breadcrumb
      @page_type = page_type

      @breadcrumb = Breadcrumbs.new if breadcrumb.blank?
    end

    def title_with_hierarchies
      current_page = extra_title.present? ? [title, extra_title] : [title]
      current_page += breadcrumb.titles.reverse if breadcrumb.present?
      current_page
    end

    def page_title
      result = title_with_hierarchies.join(separator)
      if base_app_name.present?
        result += separator + base_app_name
      end
      result
    end

    def json_lds
      output = []
      output << breadcrumb.json_ld(current_page_title: title) if breadcrumb.present?
      output << page_type.json_ld if page_type.present?
      output.join
    end

    def default_image_url
      PageStructuredData.default_image_url
    end

    private

    def base_app_name
      PageStructuredData.base_app_name
    end

    def separator
      ' - '
    end
  end
end
