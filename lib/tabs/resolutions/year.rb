module Tabs
  module Resolutions
    module Year
      extend Tabs::Resolutionable
      extend self

      PATTERN = "%Y"

      def serialize(timestamp)
        timestamp.strftime(PATTERN)
      end

      def deserialize(str)
        dt = DateTime.strptime(str, PATTERN)
        self.normalize(dt)
      end

      def from_seconds(s)
        s / 31536000
      end

      def normalize(ts)
        Time.utc(ts.year)
      end

    end
  end
end
