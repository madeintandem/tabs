module Tabs
  module Resolutions
    module Month
      extend self

      PATTERN = "%Y-%m"

      def serialize(timestamp)
        timestamp.strftime(PATTERN)
      end

      def deserialize(str)
        dt = DateTime.strptime(str, PATTERN)
        self.normalize(dt)
      end

      def normalize(ts)
        Time.utc(ts.year, ts.month)
      end

    end
  end
end
