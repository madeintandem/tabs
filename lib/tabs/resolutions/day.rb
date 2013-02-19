module Tabs
  module Resolutions
    module Day

      PATTERN = "%Y-%m-%d"

      def serialize(timestamp)
        timestamp.strftime(PATTERN)
      end

      def deserialize(str)
        dt = DateTime.strptime(str, PATTERN)
        Time.now(dt.year, dt.month, dt.date)
      end

    end
  end
end
