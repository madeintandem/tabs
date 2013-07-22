module Tabs
  module Helpers
    extend self

    def timestamp_range(period, resolution)
      period = normalize_period(period, resolution)
      dt = period.first
      [].tap do |arr|
        arr << dt
        while (dt = dt + 1.send(resolution)) <= period.last
          arr << dt.utc
        end
      end
    end

    def normalize_period(period, resolution)
      period_start = Tabs::Resolution.normalize(resolution, period.first.utc)
      period_end = Tabs::Resolution.normalize(resolution, period.last.utc)
      (period_start..period_end)
    end
  end
end
