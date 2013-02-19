module Minute
  module Resolutions
    module Month

      PATTERN = "%Y-%m-%d-%H-%M"

      def serialize(timestamp)
        timestamp.strftime(PATTERN)
      end

      def deserialize(str)
        dt = DateTime.strptime(str, PATTERN)
        Time.new(dt.year, dt.month, dt.date, dt.hour, dt.minute)
      end

    end
  end
end
