module Tabs
  module Metrics
    class Counter
      include Storage
      include Helpers

      attr_reader :key

      def initialize(key)
        @key = key
      end

      def increment(timestamp=Time.now)
        timestamp.utc
        Tabs::Resolution.all.each do |resolution|
          increment_resolution(resolution, timestamp)
        end
        increment_total
        true
      end

      def stats(period, resolution)
        timestamps = timestamp_range period, resolution
        keys = timestamps.map do |ts|
          "stat:counter:#{key}:count:#{Tabs::Resolution.serialize(resolution, ts)}"
        end

        values = mget(*keys).map do |v|
          {
            "timestamp" => timestamps.shift,
            "count" => (v || 0).to_i
          }.with_indifferent_access
        end

        Stats.new(period, resolution, values)
      end

      def total
        (get("stat:counter:#{key}:total") || 0).to_i
      end

      def drop!
        del_by_prefix("stat:counter:#{key}")
      end

      private

      def increment_resolution(resolution, timestamp)
        formatted_time = Tabs::Resolution.serialize(resolution, timestamp)
        stat_key = "stat:counter:#{key}:count:#{formatted_time}"
        incr(stat_key)
      end

      def increment_total
        incr("stat:counter:#{key}:total")
      end

    end
  end
end
