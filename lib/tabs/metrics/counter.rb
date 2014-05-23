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

      def decrement(timestamp=Time.now)
        timestamp.utc
        Tabs::Resolution.all.each do |resolution|
          decrement_resolution(resolution, timestamp)
        end
        decrement_total
        true
      end

      def stats(period, resolution)
        timestamps = timestamp_range period, resolution
        keys = timestamps.map do |timestamp|
          storage_key(resolution, timestamp)
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

      def drop_by_resolution!(resolution)
        del_by_prefix("stat:counter:#{key}:count:#{resolution}")
      end

      def storage_key(resolution, timestamp)
        formatted_time = Tabs::Resolution.serialize(resolution, timestamp)
        "stat:counter:#{key}:count:#{resolution}:#{formatted_time}"
      end

      private

      def increment_resolution(resolution, timestamp)
        store_key = storage_key(resolution, timestamp)
        incr(store_key)
        Tabs::Resolution.expire(resolution, store_key, timestamp)
      end

      def increment_total
        incr("stat:counter:#{key}:total")
      end

      def decrement_resolution(resolution, timestamp)
        store_key = storage_key(resolution, timestamp)
        val = decr(store_key)

         if !Tabs::Config.negative_metric && val < 0
          return increment_resolution(resolution, timestamp)
        end

        Tabs::Resolution.expire(resolution, store_key, timestamp)
        val
      end

      def decrement_total
        val = decr("stat:counter:#{key}:total")

        if !Tabs::Config.negative_metric && val < 0
         val = increment_total
        end

        val
      end
    end
  end
end
