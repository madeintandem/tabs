module Tabs
  module Helpers
    extend self

    def timestamps_in_period(period, resolution)
      timestamps = []
      dt = period.first
      while dt <= period.last
        timestamps << dt.utc
        dt += 1.send(resolution.to_sym)
      end
      timestamps
    end

    def normalize_period(period)
      period_start = Time.new(period.first.year, period.first.month, period.first.day, period.first.hour, 0, 0)
      period_end = Time.new(period.last.year, period.last.month, period.last.day, period.last.hour, 0, 0)
      (period_start.utc..period_end.utc)
    end

    def extract_date_from_key(stat_key, resolution)
      pattern = Tabs::RESOLUTIONS[resolution]
      date_str = stat_key.split(":").last
      now = DateTime.strptime(date_str, pattern)
      Time.utc(now.year, now.month, now.day, now.hour, 0, 0)
    end

  end
end
