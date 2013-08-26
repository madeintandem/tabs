module Tabs
  module Metrics
    class Value
      include Storage
      include Helpers

      attr_reader :key

      def initialize(key)
        @key = key
      end

      def record(value, timestamp=Time.now)
        timestamp.utc
        Tabs::Resolution.all.each do |resolution|
          formatted_time = Tabs::Resolution.serialize(resolution, timestamp)
          stat_key = "stat:value:#{key}:data:#{formatted_time}"
          update_values(stat_key, value)
        end
        true
      end

      def stats(period, resolution)
        timestamps = timestamp_range period, resolution
        keys = timestamps.map do |ts|
          formatted_time = Tabs::Resolution.serialize(resolution, ts)
          "stat:value:#{key}:data:#{formatted_time}"
        end

        values = mget(*keys).map do |v|
          value = v.nil? ? default_value(0) : v
          value = Hash[value.map { |k, i| [k, to_numeric(i)] }]
          value["timestamp"] = timestamps.shift
          value.with_indifferent_access
        end

        Stats.new(period, resolution, values)
      end

      def drop!
        del_by_prefix("stat:value:#{key}")
      end

      private

      def update_values(stat_key, value)
        count = update_count(stat_key)
        sum = update_sum(stat_key, value)
        update_min(stat_key, value)
        update_max(stat_key, value)
        update_avg(stat_key, sum, count)
      end

      def update_count(stat_key)
        hincrby(stat_key, "count", 1)
      end

      def update_sum(stat_key, value)
        hincrby(stat_key, "sum", value)
      end

      def update_min(stat_key, value)
        min = (hget(stat_key, "min") || 0).to_i
        hset(stat_key, "min", value) if value < min || min == 0
      end

      def update_max(stat_key, value)
        max = (hget(stat_key, "max") || 0).to_i
        hset(stat_key, "max", value) if value > max || max == 0
      end

      def update_avg(stat_key, sum, count)
        avg = sum.to_f / count.to_f
        hset(stat_key, "avg", avg)
      end

      def default_value(nil_value=nil)
        { "count" => 0, "min" => nil_value, "max" => nil_value, "sum" => 0, "avg" => 0 }
      end

    end
  end
end
