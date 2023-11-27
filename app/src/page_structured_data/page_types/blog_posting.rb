# frozen_string_literal: true

module PageStructuredData
  module PageTypes
    # Basic page metadata for any page
    class BlogPosting
      attr_reader :headline, :images, :published_at, :updated_at, :authors

      def initialize(headline:, published_at:, updated_at:, images: [], authors: [])
        @headline = headline
        @images = images
        @published_at = published_at
        @updated_at = updated_at
        @authors = authors
      end

      def json_ld # rubocop:disable Metrics/MethodLength
        node = {
          '@context': 'https://schema.org',
          '@type': 'BlogPosting',
        }

        node[:headline] = headline
        node[:image] = images
        node[:datePublished] = published_at
        node[:dateModified] = updated_at

        author_hash = authors.map do |author|
          {
            '@type': 'Person',
            name: author[:name],
            url: author[:url],
          }
        end

        node[:author] = author_hash

        %(
        <script type="application/ld+json">
          #{node.to_json}
          </script>
        )
      end
    end
  end
end
