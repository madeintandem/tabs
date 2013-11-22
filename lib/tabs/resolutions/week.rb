module Tabs
  module Resolutions
    module Week
      include Tabs::Resolutionable
      extend self

      PATTERN = "%Y-%m-%d"

      def name
        :week
      end

      def serialize(timestamp)
        normalize(timestamp).strftime(PATTERN)
      end

      def deserialize(str)
        dt = DateTime.strptime(str, PATTERN)
        self.normalize(dt)
      end

      def from_seconds(s)
        s / 1.week
      end

      def to_seconds
        1.week
      end

      def add(ts, num)
        ts + num.weeks
      end

      def normalize(ts)
        Time.utc(ts.year, ts.month, ts.day).beginning_of_week
      end

    end
  end
end
