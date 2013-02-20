module Tabs
  module Helpers
    extend self

    def timestamp_range(period, resolution, default_value=0)
      period = normalize_period(period, resolution)
      dt = period.first
      Hash[([].tap do |arr|
        while (dt = dt + 1.send(resolution)) <= period.last
          arr << dt.utc
        end
      end).map { |ts| [ts, default_value] }]
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

    def fill_missing_dates(period, date_value_pairs, resolution, default_value=0)
      all_timestamps = timestamp_range(period, resolution, default_value)
      merged = all_timestamps.merge(Hash[date_value_pairs])
      merged.to_a
    end

  end
end
