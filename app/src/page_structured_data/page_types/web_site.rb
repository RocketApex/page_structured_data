# frozen_string_literal: true

module PageStructuredData
  module PageTypes
    # WebSite structured data for a page
    class WebSite
      include SchemaNode

      attr_reader :name, :url, :description, :publisher, :potential_action

      def initialize(name:, url:, description: nil, publisher: nil, potential_action: nil)
        @name = name
        @url = url
        @description = description
        @publisher = publisher
        @potential_action = potential_action
      end

      def to_h
        compact_node(
          '@context': 'https://schema.org',
          '@type': 'WebSite',
          name: name,
          url: url,
          description: description,
          publisher: object_to_h(publisher),
          potentialAction: object_to_h(potential_action)
        )
      end

      def json_ld
        %(
        <script type="application/ld+json">
          #{to_h.to_json}
          </script>
        )
      end

    end
  end
end
