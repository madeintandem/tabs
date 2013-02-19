module Tabs
  module Resolutions
    module Year

      PATTERN = "%Y"

      def serialize(timestamp)
        timestamp.strftime(PATTERN)
      end

      def deserialize(str)
        dt = DateTime.strptime(str, PATTERN)
        Time.new(dt.year)
      end

    end
  end
end
