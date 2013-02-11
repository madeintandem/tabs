module Tabs
  module Metrics
    class Value
      include Tabs::Storage

      attr_reader :key

      def initialize(key)
        @key = key
      end

    end
  end
end
