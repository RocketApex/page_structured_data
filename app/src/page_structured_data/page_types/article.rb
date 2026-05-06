# frozen_string_literal: true

module PageStructuredData
  module PageTypes
    # Shared structured data for schema.org article-like page types.
    class Article
      include SchemaNode

      attr_reader :headline, :images, :published_at, :updated_at, :authors, :article_body, :url,
                  :interaction_statistics, :likes_count, :comments_count, :shares_count

      def initialize(headline:, published_at:, updated_at:, images: [], authors: [], image: nil, article_body: nil, text: nil,
                     url: nil, interaction_statistics: [], likes_count: nil, comments_count: nil, shares_count: nil)
        @headline = headline
        @images = image.present? ? Array(image) : Array(images)
        @published_at = published_at
        @updated_at = updated_at
        @authors = Array(authors)
        @article_body = article_body || text
        @url = url
        @interaction_statistics = Array(interaction_statistics)
        @likes_count = likes_count
        @comments_count = comments_count
        @shares_count = shares_count
      end

      def to_h
        node = {
          '@context': 'https://schema.org',
          '@type': schema_type,
          headline: headline,
          image: images,
          datePublished: published_at,
          dateModified: updated_at,
          author: authors.map { |author| author_to_h(author) },
        }

        node[:articleBody] = article_body if article_body.present?
        node[:url] = url if url.present?
        node[:interactionStatistic] = interaction_statistics_to_h if interaction_statistics_to_h.any?

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

      def schema_type
        raise NotImplementedError, "#{self.class.name} must define #schema_type"
      end

      def author_to_h(author)
        return object_to_h(author) if author.respond_to?(:to_h) && !author.is_a?(Hash)

        compact_node(
          '@type': 'Person',
          name: author[:name] || author['name'],
          url: author[:url] || author['url'],
          image: author[:image] || author['image'],
          sameAs: author[:same_as] || author[:sameAs] || author['same_as'] || author['sameAs']
        )
      end

      def interaction_statistics_to_h
        @interaction_statistics_to_h ||= all_interaction_statistics.map do |interaction_statistic|
          if interaction_statistic.respond_to?(:to_h)
            interaction_statistic.to_h
          else
            interaction_statistic
          end
        end
      end

      def all_interaction_statistics
        interaction_statistics + count_interaction_statistics
      end

      def count_interaction_statistics
        [
          count_interaction_statistic(:like, likes_count),
          count_interaction_statistic(:comment, comments_count),
          count_interaction_statistic(:share, shares_count),
        ].compact
      end

      def count_interaction_statistic(interaction_type, count)
        return if count.nil?

        InteractionStatistic.new(interaction_type: interaction_type, user_interaction_count: count)
      end
    end
  end
end
