# frozen_string_literal: true

module PageStructuredData
  module PageTypes
    # schema.org InteractionCounter structured data.
    class InteractionStatistic
      include SchemaNode

      ACTION_TYPES = {
        like: 'LikeAction',
        likes: 'LikeAction',
        comment: 'CommentAction',
        comments: 'CommentAction',
        share: 'ShareAction',
        shares: 'ShareAction',
      }.freeze

      attr_reader :interaction_type, :user_interaction_count, :interaction_service

      def self.like(user_interaction_count)
        new(interaction_type: :like, user_interaction_count: user_interaction_count)
      end

      def self.comment(user_interaction_count)
        new(interaction_type: :comment, user_interaction_count: user_interaction_count)
      end

      def self.share(user_interaction_count)
        new(interaction_type: :share, user_interaction_count: user_interaction_count)
      end

      def initialize(interaction_type:, user_interaction_count:, interaction_service: nil)
        @interaction_type = interaction_type
        @user_interaction_count = user_interaction_count
        @interaction_service = interaction_service
      end

      def to_h
        compact_node(
          '@type': 'InteractionCounter',
          interactionType: interaction_type_to_h,
          userInteractionCount: user_interaction_count,
          interactionService: object_to_h(interaction_service)
        )
      end

      private

      def interaction_type_to_h
        return object_to_h(interaction_type) if interaction_type.respond_to?(:to_h)

        type = ACTION_TYPES.fetch(interaction_type.to_s.to_sym, interaction_type.to_s)

        { '@type': type }
      end
    end
  end
end
