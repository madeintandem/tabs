module Tabs
  module Metrics
    class Counter

      attr_reader :key

      def initialize(key)
        @key = key
      end

      def increment
        writer = Tabs::Stats::Writer.new(key, DateTime.now)
        writer.increment
      end

      def stats(period_start, period_end, resolution)

      end

      private

    end
  end
end
