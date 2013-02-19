module Tabs
  module Resolutions
    module Week

      PATTERN = "%Y-%W"

      def serialize(timestamp)
        timestamp.strftime(PATTERN)
      end

      def deserialize(str)
        year, week = str.split("-").map(&:to_i)
        week = 1 if week == 0
        dt = DateTime.strptime("#{year}-#{week}", PATTERN)
        dt = dt.beginning_of_week
        Time.now(dt.year, dt.month, dt.date)
      end

    end
  end
end
