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

      def start(token, timestamp=Time.now)
        Token.new(token, key).start(timestamp)
        true
      end

      def complete(token, timestamp=Time.now)
        Token.new(token, key).complete(timestamp)
        true
      end

      def stats(period, resolution)
        range = timestamp_range(period, resolution)
        started_tokens = tokens_for_period(range, resolution, "started")
        completed_tokens = tokens_for_period(range, resolution, "completed")
        matching_tokens = started_tokens & completed_tokens
        completion_rate = round_float(matching_tokens.size.to_f / range.size)
        elapsed_times = matching_tokens.map { |t| t.time_elapsed(resolution) }
        average_completion_time = (elapsed_times.inject(&:+)) / matching_tokens.size
        {
          started: started_tokens.size,
          completed: completed_tokens.size,
          completed_within_period: matching_tokens.size,
          completion_rate: completion_rate,
          average_completion_time: average_completion_time
        }
      end

      def drop!
        del_by_prefix("stat:task:#{key}")
      end

      private

      def tokens_for_period(range, resolution, type)
        keys = Task::Token.keys_for_range(key, range, resolution, type)
        mget(*keys).compact.map(&:to_a).flatten.map { |t| Token.new(t, key) }
      end

    end
  end
end
