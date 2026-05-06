# frozen_string_literal: true

module PageStructuredData
  module PageTypes
    # Basic page metadata for any page
    class BlogPosting < Article
      private

      def schema_type
        'BlogPosting'
      end
    end
  end
end
