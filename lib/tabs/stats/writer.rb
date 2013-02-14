module Tabs
  module Stats
    class Writer
      include Tabs::Storage

      attr_reader :key
      attr_reader :timestamp

      def initialize(key, timestamp)
        @key = key
        @timestamp = timestamp
      end

      def increment
        Tabs::Stats::RESOLUTIONS.each do |res|
          formated_time = timestamp.strftime(res)
          stat_key = "{key}:#{formated_time}"
          sadd(key, stat_key)
          incr(stat_key)
        end
      end

      def set_value(value)
        Tabs::Stats::RESOLUTIONS.each do |res|
          formated_time = timestamp.strftime(res)
          stat_key = "{key}:#{formated_time}"
          sadd(key, stat_key)
          incr(stat_key)
        end
      end

    end
  end
end
