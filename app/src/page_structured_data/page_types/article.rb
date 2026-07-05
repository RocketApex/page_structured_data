# frozen_string_literal: true

module PageStructuredData
  module PageTypes
    # Shared structured data for schema.org article-like page types.
    class Article
      include SchemaNode

      attr_reader :headline, :images, :published_at, :updated_at, :authors, :description, :article_body, :url,
                  :main_entity_of_page, :publisher, :article_section, :keywords, :word_count, :in_language,
                  :interaction_statistics, :likes_count, :comments_count, :shares_count

      def initialize(headline:, published_at:, updated_at:, images: [], authors: [], image: nil, article_body: nil, text: nil,
                     description: nil, url: nil, main_entity_of_page: nil, publisher: nil, article_section: nil,
                     keywords: nil, word_count: nil, in_language: nil, interaction_statistics: [], likes_count: nil,
                     comments_count: nil, shares_count: nil)
        @headline = headline
        @images = image.present? ? Array(image) : Array(images)
        @published_at = published_at
        @updated_at = updated_at
        @authors = Array(authors)
        @description = description
        @article_body = article_body || text
        @url = url
        @main_entity_of_page = main_entity_of_page
        @publisher = publisher
        @article_section = article_section
        @keywords = keywords
        @word_count = word_count
        @in_language = in_language
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

        node[:description] = description if description.present?
        node[:articleBody] = article_body if article_body.present?
        node[:url] = url if url.present?
        node[:mainEntityOfPage] = object_to_h(main_entity_of_page) if main_entity_of_page.present?
        node[:publisher] = object_to_h(publisher) if publisher.present?
        node[:articleSection] = article_section if article_section.present?
        node[:keywords] = keywords if keywords.present?
        node[:wordCount] = word_count if word_count.present?
        node[:inLanguage] = object_to_h(in_language) if in_language.present?
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

      def warnings
        required_attribute_warnings(
          headline: headline,
          published_at: published_at,
          updated_at: updated_at
        ) + author_warnings + publisher_warnings + interaction_statistic_warnings
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

      def author_warnings
        authors.each_with_index.flat_map do |author, index|
          if author.respond_to?(:warnings)
            author.warnings.map { |warning| "author #{index + 1}: #{warning}" }
          else
            author_hash = object_to_h(author) || {}
            required_attribute_warnings(name: author_hash[:name] || author_hash['name']).map do |warning|
              "author #{index + 1}: #{warning}"
            end
          end
        end
      end

      def publisher_warnings
        return [] unless publisher.respond_to?(:warnings)

        publisher.warnings.map { |warning| "publisher: #{warning}" }
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

      def interaction_statistic_warnings
        all_interaction_statistics.each_with_index.flat_map do |interaction_statistic, index|
          next [] unless interaction_statistic.respond_to?(:warnings)

          interaction_statistic.warnings.map { |warning| "interaction statistic #{index + 1}: #{warning}" }
        end
      end
    end
  end
end
