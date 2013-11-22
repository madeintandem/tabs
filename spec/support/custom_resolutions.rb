module BadlyFormedResolution
  include Tabs::Resolutionable
  extend self
end

module WellFormedResolution
  include Tabs::Resolutionable
  extend self

  PATTERN = "%Y-%m-%d-%H-%M-%S"

  def serialize(timestamp)
    timestamp.strftime(PATTERN)
  end

  def deserialize(str)
    dt = DateTime.strptime(str, PATTERN)
    self.normalize(dt)
  end

  def from_seconds(s)
    s / 1
  end

  def add(ts, num)
    ts + num.seconds
  end

  def normalize(ts)
    Time.utc(ts.year, ts.month, ts.day, ts.hour, ts.min, ts.sec)
  end
end
