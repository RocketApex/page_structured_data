# frozen_string_literal: true

module PageStructuredData
  module PageTypes
    # schema.org Person structured data.
    class Person
      include SchemaNode

      attr_reader :name, :url, :image, :same_as

      def initialize(name:, url: nil, image: nil, same_as: [])
        @name = name
        @url = url
        @image = image
        @same_as = Array(same_as)
      end

      def to_h
        compact_node(
          '@type': 'Person',
          name: name,
          url: url,
          image: image,
          sameAs: same_as
        )
      end
    end
  end
end
