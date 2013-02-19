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
        Time.new(ts.year, ts.month, ts.date, ts.hour)
      end

    end
  end
end
