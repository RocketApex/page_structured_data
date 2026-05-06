# frozen_string_literal: true

module PageStructuredData
  module PageTypes
    # Shared helpers for schema.org hash values.
    module SchemaNode
      private

      def compact_node(node)
        node.each_with_object({}) do |(key, value), compacted|
          next if blank_schema_value?(value)

          compacted[key] = value
        end
      end

      def object_to_h(object)
        return object.to_h if object.respond_to?(:to_h)

        object
      end

      def blank_schema_value?(value)
        value.nil? || (value.respond_to?(:empty?) && value.empty?)
      end
    end
  end
end
