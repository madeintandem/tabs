require "spec_helper"

describe Tabs::Metrics::Counter do

  describe ".increment" do

    it "increments the value for the expected periods" do
      counter = Tabs.create_metric("foo", "counter")
      counter.increment
      now = Time.now.utc time = Time.utc(now.year, now.month, now.day, now.hour)
      stats = counter.stats(((Time.now - 2.hours)..(Time.now + 4.hours)), :hour)
      expect(stats).to include({ time => 1 })
    end
  end


  describe ".stats" do

  end

end
