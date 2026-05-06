# frozen_string_literal: true

module PageStructuredData
  module PageTypes
    # Shared structured data for schema.org article-like page types.
    class Article
      attr_reader :headline, :images, :published_at, :updated_at, :authors

      def initialize(headline:, published_at:, updated_at:, images: [], authors: [])
        @headline = headline
        @images = images
        @published_at = published_at
        @updated_at = updated_at
        @authors = authors
      end

      def to_h
        {
          '@context': 'https://schema.org',
          '@type': schema_type,
          headline: headline,
          image: images,
          datePublished: published_at,
          dateModified: updated_at,
          author: authors.map do |author|
            {
              '@type': 'Person',
              name: author[:name],
              url: author[:url],
            }
          end,
        }
      end

      def json_ld
        %(
        <script type="application/ld+json">
          #{to_h.to_json}
          </script>
        )
      end

      private

      def schema_type
        raise NotImplementedError, "#{self.class.name} must define #schema_type"
      end
    end
  end
end
