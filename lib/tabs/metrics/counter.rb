module Tabs
  module Metrics
    class Counter
      include Tabs::Storage

      attr_reader :key

      def initialize(key)
        @key = key
      end

    end
  end
end
