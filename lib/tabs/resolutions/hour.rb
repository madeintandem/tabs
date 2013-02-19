module Tabs
  module Resolutions
    module Hour

      PATTERN = "%Y-%m-%d-%H"

      def serialize(timestamp)
        timestamp.strftime(PATTERN)
      end

      def deserialize(str)
        dt = DateTime.strptime(str, PATTERN)
        Time.new(dt.year, dt.month, dt.date, dt.hour)
      end

    end
  end
end
