module Tabs
  module Resolutions
    module Week
      extend self

      PATTERN = "%Y-%W"

      def serialize(timestamp)
        timestamp.strftime(PATTERN)
      end

      def deserialize(str)
        year, week = str.split("-").map(&:to_i)
        week = 1 if week == 0
        dt = DateTime.strptime("#{year}-#{week}", PATTERN)
        self.normalize(dt)
      end

      def normalize(ts)
        Time.utc(ts.year, ts.month, ts.day).beginning_of_week
      end

    end
  end
end
