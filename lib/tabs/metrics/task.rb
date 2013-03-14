module Tabs
  module Metrics
    class Task
      include Tabs::Storage
      include Tabs::Helpers

      attr_reader :key

      def initialize(key)
        @key = key
      end

    end
  end
end
