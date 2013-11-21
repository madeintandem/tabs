module Tabs
  module Metrics
    class Task
      class Token
        include Storage

        attr_reader :key
        attr_reader :token

        def initialize(token, key)
          @key = key
          @token = token
        end

        def start(timestamp=Time.now)
          self.start_time = timestamp.utc
          sadd(tokens_storage_key, token)
          Tabs::Resolution.all.each { |res| record_start(res, start_time) }
        end

        def complete(timestamp=Time.now)
          self.complete_time = timestamp.utc
          unless sismember(tokens_storage_key, token)
            raise UnstartedTaskMetricError.new("No task for metric '#{key}' was started with token '#{token}'")
          end
          Tabs::Resolution.all.each { |res| record_complete(res, complete_time) }
        end

        def time_elapsed(resolution)
          Tabs::Resolution.from_seconds(resolution, complete_time - start_time)
        end

        def ==(other_token)
          self.token == other_token.token
        end

        def to_s
          "#{super}:#{token}"
        end

        private

        def storage_key(resolution, timestamp, type)
          formatted_time = Tabs::Resolution.serialize(resolution, timestamp)
          "stat:task:#{key}:#{type}:#{resolution}:#{formatted_time}"
        end

        def started_storage_key
          "stat:task:#{key}:#{token}:started_time"
        end

        def completed_storage_key
          "stat:task:#{key}:#{token}:completed_time"
        end

        def tokens_storage_key
          "stat:task:#{key}:tokens"
        end

        def record_start(resolution, timestamp)
          sadd(storage_key(resolution, timestamp, "started"), token)
        end

        def record_complete(resolution, timestamp)
          sadd(storage_key(resolution, timestamp, "completed"), token)
        end

        def start_time=(timestamp)
          set(started_storage_key, timestamp)
          @start_time = timestamp
        end

        def start_time
          Time.parse(get(started_storage_key))
        end

        def complete_time=(timestamp)
          set(completed_storage_key, timestamp)
          @complete_time = timestamp
        end

        def complete_time
          Time.parse(get(completed_storage_key))
        end

      end
    end
  end
end
