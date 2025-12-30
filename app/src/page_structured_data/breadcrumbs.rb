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

    def json_ld(current_page_title:) # rubocop:disable Metrics/MethodLength
      node = {
        '@context': 'https://schema.org',
        '@type': 'BreadcrumbList',
        'itemListElement': [],
      }

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

      node['itemListElement'] = items

      %(
      <script type="application/ld+json">
        #{node.to_json}
        </script>
      )
    end
  end
end
