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
        Tabs::RESOLUTIONS.each { |res| record_complete(res, token, Time.now.utc) }
      end

      def stats(period, resolution)
        range = timestamp_range(period, resolution)
        started_tokens = tokens_for_period(range, resolution, "started")
        completed_tokens = tokens_for_period(range, resolution, "completed")
        matching = started_tokens & completed_tokens
        {
          started: started_tokens.size,
          completed: completed_tokens.size,
          completed_within_period: matching.size,
          completion_rate: (((matching.size.to_f / range.size)*100).round / 100.0)
        }
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

      def tokens_for_period(range, resolution, type)
        keys = keys_for_period(range, resolution, type)
        mget(*keys).compact.map(&:to_a).flatten
      end

      def keys_for_period(range, resolution, type)
        range.map do |date|
          formatted_time = Tabs::Resolution.serialize(resolution, date)
          "stat:#{type}:#{key}:#{formatted_time}"
        end
      end

    end
  end
end
