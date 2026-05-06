# frozen_string_literal: true

module PageStructuredData
  module PageTypes
    # Organization structured data for a page
    class Organization
      attr_reader :name, :url, :description, :logo, :same_as, :parent_organization, :founder

      def initialize(name:, url:, description: nil, logo: nil, same_as: [], parent_organization: nil, founder: nil)
        @name = name
        @url = url
        @description = description
        @logo = logo
        @same_as = same_as
        @parent_organization = parent_organization
        @founder = founder
      end

      def to_h # rubocop:disable Metrics/MethodLength
        node = {
          '@context': 'https://schema.org',
          '@type': 'Organization',
        }

        node[:name] = name
        node[:url] = url
        node[:description] = description if description.present?
        node[:logo] = logo if logo.present?
        node[:sameAs] = same_as if same_as.present?
        node[:founder] = founder_to_h if founder.present?

        if parent_organization.present?
          node[:parentOrganization] = {
            '@type': 'Organization',
            name: parent_organization[:name],
            url: parent_organization[:url],
          }
        end

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

      def founder_to_h
        return founder.to_h if founder.respond_to?(:to_h)

        founder
      end
    end
  end
end
