module Tabs
  module Resolutions
    module Day
      extend self

      PATTERN = "%Y-%m-%d"

      def serialize(timestamp)
        timestamp.strftime(PATTERN)
      end

      def deserialize(str)
        dt = DateTime.strptime(str, PATTERN)
        self.normalize(dt)
      end

      def normalize(ts)
        Time.utc(ts.year, ts.month, ts.day)
      end

    end
  end
end
