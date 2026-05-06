# frozen_string_literal: true

module PageStructuredData
  module PageTypes
    # Organization structured data for a page
    class Organization
      attr_reader :name, :url, :logo, :same_as, :parent_organization

      def initialize(name:, url:, logo: nil, same_as: [], parent_organization: nil)
        @name = name
        @url = url
        @logo = logo
        @same_as = same_as
        @parent_organization = parent_organization
      end

      def json_ld # rubocop:disable Metrics/MethodLength
        node = {
          '@context': 'https://schema.org',
          '@type': 'Organization',
        }

        node[:name] = name
        node[:url] = url
        node[:logo] = logo if logo.present?
        node[:sameAs] = same_as if same_as.present?

        if parent_organization.present?
          node[:parentOrganization] = {
            '@type': 'Organization',
            name: parent_organization[:name],
            url: parent_organization[:url],
          }
        end

        %(
        <script type="application/ld+json">
          #{node.to_json}
          </script>
        )
      end
    end
  end
end
