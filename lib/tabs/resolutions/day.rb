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
        Time.new(ts.year, ts.month, ts.date)
      end

    end
  end
end
