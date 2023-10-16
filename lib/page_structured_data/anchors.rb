# frozen_string_literal: true

module PageStructuredData
  # Basic page metadata for any page
  class Anchors
    attr_reader :anchors

    def initialize(anchors:)
      @anchors = anchors
    end

    def titles
      anchors.keys
    end

    def anchor_for(title)
      "##{anchors[title]}"
    end
  end
end
