# frozen_string_literal: true

module PageStructuredData
  module PageTypes
    # WebSite structured data for a page
    class WebSite
      attr_reader :name, :url, :description, :publisher, :potential_action

      def initialize(name:, url:, description: nil, publisher: nil, potential_action: nil)
        @name = name
        @url = url
        @description = description
        @publisher = publisher
        @potential_action = potential_action
      end

      def to_h
        node = {
          '@context': 'https://schema.org',
          '@type': 'WebSite',
          name: name,
          url: url,
        }

        node[:description] = description if description.present?
        node[:publisher] = publisher_to_h if publisher.present?
        node[:potentialAction] = potential_action if potential_action.present?

        node
      end

      def json_ld
        %(
        <script type="application/ld+json">
          #{to_h.to_json}
          </script>
        )
      end

      private

      def publisher_to_h
        return publisher.to_h if publisher.respond_to?(:to_h)

        publisher
      end
    end
  end
end
