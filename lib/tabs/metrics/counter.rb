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
        Tabs::RESOLUTIONS.each do |resolution|
          increment_resolution(resolution, timestamp)
        end
        increment_total
        true
      end

      def stats(period, resolution)
        period = normalize_period(period, resolution)
        keys = smembers("stat:counter:#{key}:keys:#{resolution}")
        dates = keys.map { |k| extract_date_from_key(k, resolution) }
        values = mget(*keys).map(&:to_i)
        pairs = dates.zip(values)
        filtered_pairs = pairs.find_all { |p| period.cover?(p[0]) }
        filtered_pairs = fill_missing_dates(period, filtered_pairs, resolution)
        filtered_pairs.map { |p| Hash[[p]] }
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
        sadd("stat:counter:#{key}:keys:#{resolution}", stat_key)
        incr(stat_key)
      end

      def increment_total
        incr("stat:counter:#{key}:total")
      end

    end
  end
end
