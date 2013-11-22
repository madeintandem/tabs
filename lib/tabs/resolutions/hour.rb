module Tabs
  module Resolutions
    module Hour
      include Tabs::Resolutionable
      extend self

      PATTERN = "%Y-%m-%d-%H"

      def name
        :hour
      end

      def serialize(timestamp)
        timestamp.strftime(PATTERN)
      end

      def deserialize(str)
        dt = DateTime.strptime(str, PATTERN)
        self.normalize(dt)
      end

      def from_seconds(s)
        s / 1.hour
      end

      def to_seconds
        1.hour
      end

      def add(ts, num)
        ts + num.hours
      end

      def normalize(ts)
        Time.utc(ts.year, ts.month, ts.day, ts.hour)
      end

    end
  end
end
