module Tabs
  module Metrics
    class Task
      include Tabs::Storage
      include Tabs::Helpers

      class UnstartedTaskMetricError < Exception; end

      attr_reader :key

      def initialize(key)
        @key = key
      end

      def start(token)
        sadd("stat:tokens:#{key}", token)
        Tabs::RESOLUTIONS.each { |res| record_start(res, token, Time.now.utc) }
      end

      def complete(token)
        unless sismember("stat:tokens:#{key}", token)
          raise UnstartedTaskMetricError.new("No task for metric '#{key}' was started with token '#{token}'")
        end
        Tabs::RESOLUTIONS.each { |res| record_end(res, token, Time.now.utc) }
      end

      def stats(period, resolution)
        range = timestamp_range(period, resolution)
        start_keys = range.map { |date| Tabs::Resolution.serialize(resolution, date) }
      end

      private

      def record_start(resolution, token, timestamp)
        formatted_time = Tabs::Resolution.serialize(resolution, timestamp)
        sadd("stat:started:#{key}:#{formatted_time}", token)
      end

      def record_complete(resolution, token, timestamp)
        formatted_time = Tabs::Resolution.serialize(resolution, timestamp)
        sadd("stat:completed:#{key}:#{formatted_time}", token)
      end

    end
  end
end
