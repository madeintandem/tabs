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
        Tabs::RESOLUTIONS.each do |resolution|
          increment_resolution(resolution, timestamp)
        end
        true
      end

      def stats(period, resolution)
        period = normalize_period(period, resolution)
        keys = smembers("stat:keys:#{key}:#{resolution}")
        dates = keys.map { |k| extract_date_from_key(k, resolution) }
        values = mget(*keys).map(&:to_i)
        pairs = dates.zip(values)
        filtered_pairs = pairs.find_all { |p| period.cover?(p[0]) }
        filtered_pairs = fill_missing_dates(period, filtered_pairs, resolution)
        filtered_pairs.map { |p| Hash[[p]] }
      end

      private

      def increment_resolution(resolution, timestamp)
        formatted_time = Tabs::Resolution.serialize(resolution, timestamp)
        stat_key = "stat:value:#{key}:count:#{formatted_time}"
        sadd("stat:keys:#{key}:#{resolution}", stat_key)
        incr(stat_key)
      end

    end
  end
end
