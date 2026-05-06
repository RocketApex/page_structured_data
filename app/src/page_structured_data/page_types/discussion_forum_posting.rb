# frozen_string_literal: true

module PageStructuredData
  module PageTypes
    # schema.org structured data for discussion forum posts.
    class DiscussionForumPosting < Article
      private

      def schema_type
        'DiscussionForumPosting'
      end
    end
  end
end
