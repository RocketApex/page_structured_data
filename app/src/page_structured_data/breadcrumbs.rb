# frozen_string_literal: true

module PageStructuredData
  # Basic page metadata for any page
  class Breadcrumbs
    attr_reader :hierarchy

    def initialize(hierarchy: [])
      @hierarchy = hierarchy
    end

    def titles
      hierarchy.pluck(:title)
    end

    def to_h(current_page_title:) # rubocop:disable Metrics/MethodLength
      {
        '@context': 'https://schema.org',
        '@type': 'BreadcrumbList',
        'itemListElement': item_list_elements(current_page_title: current_page_title),
      }
    end

    def json_ld(current_page_title:)
      %(
      <script type="application/ld+json">
        #{to_h(current_page_title: current_page_title).to_json}
        </script>
      )
    end

    private

    def item_list_elements(current_page_title:)
      items = []
      count = 0

      @hierarchy.each do |page|
        items << {
          '@type': 'ListItem',
          position: (count += 1),
          name: page[:title],
          item: page[:href],
        }
      end

      items << {
        '@type': 'ListItem',
        position: (count += 1),
        name: current_page_title,
      }
    end
  end
end
