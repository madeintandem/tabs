module Tabs
  module Metrics
    class Task
      class Token < String
        include Storage

        def self.keys_for_range(key, range, resolution, type)
          range.map do |date|
            formatted_time = Tabs::Resolution.serialize(resolution, date)
            "stat:task:#{key}:#{type}:#{formatted_time}"
          end
        end

        attr_reader :key

        def initialize(token, key)
          @key = key
          super(token)
        end

        def start_key
          "stat:started:#{key}:#{self}"
        end

        def end_key
          "stat:completed:#{key}:#{self}"
        end

        def start
          self.start_time = Time.now.utc
          sadd("stat:task:#{key}:tokens", self)
          Tabs::RESOLUTIONS.each { |res| record_start(res, start_time) }
        end

        def complete
          unless sismember("stat:task:#{key}:tokens", self)
            raise UnstartedTaskMetricError.new("No task for metric '#{key}' was started with token '#{self}'")
          end
          self.complete_time = Time.now.utc
          Tabs::RESOLUTIONS.each { |res| record_complete(res, complete_time) }
        end

        def time_elapsed(resolution)
          Tabs::Resolution.from_seconds(resolution, complete_time - start_time)
        end

        private

        def record_start(resolution, timestamp)
          formatted_time = Tabs::Resolution.serialize(resolution, timestamp)
          sadd("stat:task:#{key}:started:#{formatted_time}", self)
        end

        def record_complete(resolution, timestamp)
          formatted_time = Tabs::Resolution.serialize(resolution, timestamp)
          sadd("stat:task:#{key}:completed:#{formatted_time}", self)
        end

        def start_time=(timestamp)
          set("stat:task:#{key}:#{self}:started_time", timestamp)
          @start_time = timestamp
        end

        def start_time
          @start_time ||= Time.parse(get("stat:task:#{key}:#{self}:started_time"))
        end

        def complete_time=(timestamp)
          set("stat:task:#{key}:#{self}:completed_time", timestamp)
          @complete_time = timestamp
        end

        def complete_time
          @complete_time ||= Time.parse(get("stat:task:#{key}:#{self}:completed_time"))
        end

      end
    end
  end
end
