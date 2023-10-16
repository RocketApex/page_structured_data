# frozen_string_literal: true

module PageStructuredData
  # Basic page metadata for any page
  class Meta
    DEFAULT_IMAGE = 'common/page_meta/meta_image.png'

    attr_reader :title, :description, :image, :extra_title, :breadcrumb, :page_type

    def initialize(title:, description: nil, image: nil, # rubocop:disable Metrics/ParameterLists
                   extra_title: '', breadcrumb: nil, page_type: nil)
      @title = title
      @description = description
      @image = image
      @extra_title = extra_title
      @breadcrumb = breadcrumb
      @page_type = page_type

      @breadcrumb = PageBreadcrumbs.new if breadcrumb.blank?
    end

    def title_with_hierarchies
      current_page = extra_title.present? ? [title, extra_title] : [title]
      current_page += breadcrumb.titles.reverse if breadcrumb.present?
      current_page
    end

    def page_title
      title_with_hierarchies.join(separator) + separator + base_company_name
    end

    def json_lds
      output = []
      output << breadcrumb.json_ld(current_page_title: title) if breadcrumb.present?
      output << page_type.json_ld if page_type.present?
      output.join
    end

    private

    def separator
      ' - '
    end

    def base_company_name
      ::Common::Constants::Constants::COMPANY_NAME
    end
  end
end
