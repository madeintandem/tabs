module Tabs
  module Resolutions
    module Week
      extend Tabs::Resolutionable
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

      def seconds(s)
        s / 1.week
      end

      def add(ts, num)
        ts + num.weeks
      end

      def normalize(ts)
        Time.utc(ts.year, ts.month, ts.day).beginning_of_week
      end

    end
  end
end
