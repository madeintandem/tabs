module Tabs
  module Resolutions
    module Month

      PATTERN = "%Y-%m"

      def serialize(timestamp)
        timestamp.strftime(PATTERN)
      end

      def deserialize(str)
        dt = DateTime.strptime(str, PATTERN)
        Time.new(dt.year, dt.month)
      end

    end
  end
end
