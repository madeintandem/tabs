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
          sadd("stat:task:#{key}:tokens", token)
          Tabs::RESOLUTIONS.each { |res| record_start(res, start_time) }
        end

        def complete(timestamp=Time.now)
          self.complete_time = timestamp.utc
          unless sismember("stat:task:#{key}:tokens", token)
            raise UnstartedTaskMetricError.new("No task for metric '#{key}' was started with token '#{token}'")
          end
          Tabs::RESOLUTIONS.each { |res| record_complete(res, complete_time) }
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

        def record_start(resolution, timestamp)
          formatted_time = Tabs::Resolution.serialize(resolution, timestamp)
          sadd("stat:task:#{key}:started:#{formatted_time}", token)
        end

        def record_complete(resolution, timestamp)
          formatted_time = Tabs::Resolution.serialize(resolution, timestamp)
          sadd("stat:task:#{key}:completed:#{formatted_time}", token)
        end

        def start_time=(timestamp)
          set("stat:task:#{key}:#{token}:started_time", timestamp)
          @start_time = timestamp
        end

        def start_time
          Time.parse(get("stat:task:#{key}:#{token}:started_time"))
        end

        def complete_time=(timestamp)
          set("stat:task:#{key}:#{token}:completed_time", timestamp)
          @complete_time = timestamp
        end

        def complete_time
          Time.parse(get("stat:task:#{key}:#{token}:completed_time"))
        end

      end
    end
  end
end
