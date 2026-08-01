# frozen_string_literal: true

module PageStructuredData
  module PageTypes
    # schema.org structured data for discussion forum posts.
    class DiscussionForumPosting < Article
      def to_h
        super.tap do |node|
          node[:text] = article_body if article_body.present?
        end
      end

      def warnings
        super + discussion_forum_warnings
      end

      private

      def schema_type
        'DiscussionForumPosting'
      end

      def discussion_forum_warnings
        warnings = []
        warnings << 'author is required' if authors.empty?
        warnings << 'text or image is required' unless article_body.present? || images.any?(&:present?)
        warnings
      end
    end
  end
end
