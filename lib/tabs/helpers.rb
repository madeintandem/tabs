module Tabs
  module Helpers
    extend self

    def timestamps_in_period(period, resolution)
      period = set_week_period_to_mondays(period) if resolution == :week
      timestamps = []
      dt = period.first
      while dt <= period.last
        timestamps << dt.utc
        dt += 1.send(resolution.to_sym)
      end
      timestamps
    end

    def set_week_period_to_mondays(period)
      period_start = period.first.beginning_of_week
      period_end = period.last.beginning_of_week
      (period_start..period_end)
    end

    def normalize_period(period)
      period_start = Time.utc(period.first.year, period.first.month, period.first.day, period.first.hour, 0, 0)
      period_end = Time.utc(period.last.year, period.last.month, period.last.day, period.last.hour, 0, 0)
      (period_start..period_end)
    end

    def extract_date_from_key(stat_key, resolution)
      pattern = Tabs::RESOLUTIONS[resolution]
      date_str = stat_key.split(":").last
      if resolution == :week && date_str =~ /00$/
        year = date_str.split("-")[0]
        date_str = "#{year}-01"
      end
      date = DateTime.strptime(date_str, pattern)
      Time.utc(date.year, date.month, date.day, date.hour, 0, 0)
    end

  end
end
