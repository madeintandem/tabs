module Tabs
  module Helpers
    extend self

    def timestamp_range(period, resolution)
      period = normalize_period(period, resolution)
      dt = period.first
      [].tap do |arr|
        arr << dt
        while (dt = Tabs::Resolution.add(resolution, dt, 1)) <= period.last
          arr << dt.utc
        end
      end
    end

    def normalize_period(period, resolution)
      period_start = Tabs::Resolution.normalize(resolution, period.first.utc)
      period_end = Tabs::Resolution.normalize(resolution, period.last.utc)
      (period_start..period_end)
    end

    def to_numeric(v)
      ((float = Float(v)) && (float % 1.0 == 0) ? float.to_i : float) rescue v
    end

  end
end
