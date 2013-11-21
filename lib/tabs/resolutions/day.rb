module Tabs
  module Resolutions
    module Day
      extend Resolutionable
      extend self

      PATTERN = "%Y-%m-%d"

      def serialize(timestamp)
        timestamp.strftime(PATTERN)
      end

      def deserialize(str)
        dt = DateTime.strptime(str, PATTERN)
        self.normalize(dt)
      end

      def from_seconds(s)
        s / 1.day
      end

      def add(ts, num)
        ts + num.days
      end

      def normalize(ts)
        Time.utc(ts.year, ts.month, ts.day)
      end

      def expires_in
        Tabs::Config.expires_in[:day]
      end

      def expires?
        Tabs::Config.expires_in.key?(:day)
      end

    end
  end
end
