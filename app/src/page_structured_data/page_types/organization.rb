# frozen_string_literal: true

module PageStructuredData
  module PageTypes
    # Organization structured data for a page
    class Organization
      include SchemaNode

      attr_reader :name, :url, :description, :logo, :same_as, :parent_organization, :founder

      def initialize(name:, url:, description: nil, logo: nil, same_as: [], parent_organization: nil, founder: nil)
        @name = name
        @url = url
        @description = description
        @logo = logo
        @same_as = Array(same_as)
        @parent_organization = parent_organization
        @founder = founder
      end

      def to_h # rubocop:disable Metrics/MethodLength
        compact_node(
          '@context': 'https://schema.org',
          '@type': 'Organization',
          name: name,
          url: url,
          description: description,
          logo: logo,
          sameAs: same_as,
          founder: object_to_h(founder),
          parentOrganization: parent_organization_to_h
        )
      end

      def json_ld
        %(
        <script type="application/ld+json">
          #{to_h.to_json}
          </script>
        )
      end

      private

      def parent_organization_to_h
        return object_to_h(parent_organization) if parent_organization.respond_to?(:to_h) && !parent_organization.is_a?(Hash)
        return unless parent_organization.present?

        compact_node(
          '@type': 'Organization',
          name: parent_organization[:name] || parent_organization['name'],
          url: parent_organization[:url] || parent_organization['url']
        )
      end
    end
  end
end
