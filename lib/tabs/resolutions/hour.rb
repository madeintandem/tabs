module Tabs
  module Resolutions
    module Hour
      extend self

      PATTERN = "%Y-%m-%d-%H"

      def serialize(timestamp)
        timestamp.strftime(PATTERN)
      end

      def deserialize(str)
        dt = DateTime.strptime(str, PATTERN)
        self.normalize(dt)
      end

      def normalize(ts)
        Time.utc(ts.year, ts.month, ts.day, ts.hour)
      end

    end
  end
end
