module Tabs
  module Metrics
    class Value
      include Tabs::Storage
      include Tabs::Helpers

      attr_reader :key

      def initialize(key)
        @key = key
      end

      def record(value)
        timestamp = Time.now.utc
        Tabs::RESOLUTIONS.each do |resolution|
          formatted_time = Tabs::Resolution.serialize(timestamp, resolution)
          stat_key = "stat:value:#{key}:#{formatted_time}"
          sadd("stat:keys:#{key}:#{resolution}", stat_key)
          update_values(stat_key, value)
        end
        true
      end

      def stats(period, resolution)
      end

      private

      def update_values(stat_key, value)
        redis.multi do
          hash = get_current_hash(stat_key)
          increment(hash, value)
          update_min(hash, value)
          update_max(hash, value)
          update_avg(hash)
          set(stat_key, hash)
        end
      end

      def get_current_hash(stat_key)
        hash = get(stat_key)
        return JSON.parse(hash) if hash
        { count:0, min: 0, max: 0, sum: 0, avg: 0 }
      end

      def increment(hash, value)
        hash[:count] += 1
        hash[:sum] += value
      end

      def update_min(hash, value)
        hash[:min] = value if value < hash[:min]
      end

      def update_max(value, stat_key)
        hash[:max] = value if value > hash[:max]
      end

      def update_average(hash)
        hash[:avg] = hash[:sum] / hash[:count]
      end

    end
  end
end
