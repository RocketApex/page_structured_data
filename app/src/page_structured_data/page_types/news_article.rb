# frozen_string_literal: true

module PageStructuredData
  module PageTypes
    # Basic page metadata for any page
    class NewsArticle < Article
      private

      def schema_type
        'NewsArticle'
      end
    end
  end
end
