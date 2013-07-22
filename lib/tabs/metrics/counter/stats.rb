module Tabs
  module Metrics
    class Counter
      class Stats

        include Enumerable
        include Helpers

        attr_reader :period, :resolution, :values

        def initialize(period, resolution, values)
          @period, @resolution, @values = period, resolution, values
        end

        def first
          values.first
        end

        def last
          values.last
        end

        def total
          @total ||= values.map { |v| v["count"] }.sum
        end

        def min
          @min ||= values.min_by { |v| v["count"] }["count"]
        end

        def max
          @max ||= values.max_by { |v| v["count"] }["count"]
        end

        def avg
          return 0 if values.size.zero?
          (self.total.to_f / values.size.to_f).round(Config.decimal_precision)
        end

        def each(&block)
          values.each(&block)
        end

        def to_a
          values
        end

      end
    end
  end
end
