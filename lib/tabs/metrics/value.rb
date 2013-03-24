module Tabs
  module Metrics
    class Value
      include Storage
      include Helpers

      attr_reader :key

      def initialize(key)
        @key = key
      end

      def record(value)
        timestamp = Time.now.utc
        Tabs::RESOLUTIONS.each do |resolution|
          formatted_time = Tabs::Resolution.serialize(resolution, timestamp)
          stat_key = "stat:value:#{key}:data:#{formatted_time}"
          sadd("stat:value:#{key}:keys:#{resolution}", stat_key)
          update_values(stat_key, value)
        end
        true
      end

      def stats(period, resolution)
        period = normalize_period(period, resolution)
        keys = smembers("stat:value:#{key}:keys:#{resolution}")
        dates = keys.map { |k| extract_date_from_key(k, resolution) }
        values = mget(*keys).map { |v| JSON.parse(v) }
        pairs = dates.zip(values)
        filtered_pairs = pairs.find_all { |p| period.cover?(p[0]) }
        filtered_pairs = fill_missing_dates(period, filtered_pairs, resolution, default_value(0))
        filtered_pairs.map { |p| Hash[[p]] }
      end

      def drop!
        del_by_prefix("stat:value:#{key}")
      end

      private

      def update_values(stat_key, value)
        hash = get_current_hash(stat_key)
        increment(hash, value)
        update_min(hash, value)
        update_max(hash, value)
        update_avg(hash)
        set(stat_key, JSON.generate(hash))
      end

      def get_current_hash(stat_key)
        hash = get(stat_key)
        return JSON.parse(hash) if hash
        default_value
      end

      def increment(hash, value)
        hash["count"] += 1
        hash["sum"] += value
      end

      def update_min(hash, value)
        hash["min"] = value if hash["min"].nil? || value < hash["min"]
      end

      def update_max(hash, value)
        hash["max"] = value if hash["max"].nil? || value > hash["max"]
      end

      def update_avg(hash)
        hash["avg"] = hash["sum"] / hash["count"]
      end

      def default_value(nil_value=nil)
        { "count" => 0, "min" => nil_value, "max" => nil_value, "sum" => 0, "avg" => 0 }
      end

    end
  end
end
