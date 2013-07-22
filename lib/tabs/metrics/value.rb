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
        Tabs::RESOLUTIONS.each do |resolution|
          formatted_time = Tabs::Resolution.serialize(resolution, timestamp)
          stat_key = "stat:value:#{key}:data:#{formatted_time}"
          update_values(stat_key, value)
        end
        true
      end

      def stats(period, resolution)
        timestamps = timestamp_range period, resolution
        keys = timestamps.map do |ts|
          "stat:value:#{key}:data:#{Tabs::Resolution.serialize(resolution, ts)}"
        end

        values = mget(*keys).map do |v|
          value = v.nil? ? default_value(0) : JSON.parse(v)
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
