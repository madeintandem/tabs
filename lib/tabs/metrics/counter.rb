module Tabs
  module Metrics
    class Counter
      include Tabs::Storage
      include Tabs::Helpers

      attr_reader :key

      def initialize(key)
        @key = key
      end

      def increment
        timestamp = Time.now.utc
        Tabs::RESOLUTIONS.each do |name, pattern|
          increment_resolution(name, pattern, timestamp)
        end
        true
      end

      def stats(period, resolution)
        period = normalize_period(period)
        keys = smembers("stat:keys:#{key}:#{resolution}")
        dates = keys.map { |k| extract_date_from_key(k, resolution) }
        values = mget(*keys).map(&:to_i)
        pairs = dates.zip(values)
        filtered_pairs = pairs.find_all { |p| period.cover?(p[0]) }
        fill_missing_dates(period, filtered_pairs, resolution)
        filtered_pairs.map { |p| Hash[p] }
      end

      private

      def increment_resolution(resolution, pattern, timestamp)
        formatted_time = timestamp.strftime(pattern)
        stat_key = "stat:value:#{key}:#{formatted_time}"
        sadd("stat:keys:#{key}:#{resolution}", stat_key)
        incr(stat_key)
      end

      def fill_missing_dates(period, date_value_pairs, resolution)
        timestamps = Hash[timestamps_in_period(period, resolution).map { |ts| [ts, 0] }]
        merged = timestamps.merge(Hash[date_value_pairs])
        binding.pry
        merged.to_a
      end

    end
  end
end
