# frozen_string_literal: true

require 'active_support/core_ext/erb/util'
require 'active_support/core_ext/string/output_safety'

module PageStructuredData
  # Builds JSON-LD script tags with escaping that does not depend on host-app
  # Active Support configuration.
  module JsonLd
    module_function

    def script_tag(node)
      json = ActiveSupport::JSON.encode(node)
      escaped_json = ERB::Util.json_escape(json)

      %(
      <script type="application/ld+json">
        #{escaped_json}
        </script>
      )
    end
  end
end
