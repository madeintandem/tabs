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
        Token.new(token, key).start
        true
      end

      def complete(token)
        Token.new(token, key).complete
        true
      end

      def stats(period, resolution)
        range = timestamp_range(period, resolution)
        started_tokens = tokens_for_period(range, resolution, "started")
        completed_tokens = tokens_for_period(range, resolution, "completed")
        matching_tokens = started_tokens & completed_tokens
        completion_rate = round_float(matching_tokens.size.to_f / range.size)
        average_completion_time = (matching_tokens.map(&:time_elapsed).inject(&:+)) / matching_tokens.size
        {
          started: started_tokens.size,
          completed: completed_tokens.size,
          completed_within_period: matching_tokens.size,
          completion_rate: completion_rate,
          average_completion_time: average_completion_time
        }
      end

      private

      def tokens_for_period(range, resolution, type)
        keys = Task::Token.keys_for_range(key, range, resolution, type)
        mget(*keys).compact.map(&:to_a).flatten.map { |t| Token.new(t, key) }
      end

    end
  end
end
