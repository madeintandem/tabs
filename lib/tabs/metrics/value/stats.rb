module Tabs
  module Metrics
    class Value
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

        def count
          @count ||= values.map { |v| v["count"] }.sum
        end

        def sum
          @sum ||= values.map { |v| v["sum"] }.sum
        end

        def min
          @min ||= values.min_by { |v| v["min"] }["min"]
        end

        def max
          @max ||= values.max_by { |v| v["max"] }["max"]
        end

        def avg
          return 0 if count.zero?
          (self.sum.to_f / self.count.to_f).round(Config.decimal_precision)
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
