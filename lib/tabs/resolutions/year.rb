module Tabs
  module Resolutions
    module Year
      include Tabs::Resolutionable
      extend self

      PATTERN = "%Y"

      def name
        :year
      end

      def serialize(timestamp)
        timestamp.strftime(PATTERN)
      end

      def deserialize(str)
        dt = DateTime.strptime(str, PATTERN)
        self.normalize(dt)
      end

      def from_seconds(s)
        s / 1.year
      end

      def to_seconds
        1.year
      end

      def add(ts, num)
        ts + num.years
      end

      def normalize(ts)
        Time.utc(ts.year)
      end

    end
  end
end
