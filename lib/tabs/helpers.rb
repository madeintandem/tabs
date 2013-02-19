module Tabs
  module Helpers
    extend self

    def timestamp_range(period, resolution)
      period = normalize_period(period, resolution)
      dt = period.first
      Hash[([].tap do |arr|
        while (dt = dt + 1.send(resolution)) <= period.last
          arr << dt.utc
        end
      end).map { |ts| [ts, 0] }]
    end

    def normalize_period(period, resolution)
      period_start = Tabs::Resolution.normalize(resolution, period.first)
      period_end = Tabs::Resolution.normalize(resolution, period.last)
      (period_start..period_end)
    end

    def extract_date_from_key(stat_key, resolution)
      date_str = stat_key.split(":").last
      Tabs::Resolution.deserialize(resolution, date_str)
    end

  end
end
