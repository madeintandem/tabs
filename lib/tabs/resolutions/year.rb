module Tabs
  module Resolutions
    module Year
      extend self

      PATTERN = "%Y"

      def serialize(timestamp)
        timestamp.strftime(PATTERN)
      end

      def deserialize(str)
        dt = DateTime.strptime(str, PATTERN)
        self.normalize(dt)
      end

      def normalize(ts)
        Time.new(ts.year)
      end

    end
  end
end
