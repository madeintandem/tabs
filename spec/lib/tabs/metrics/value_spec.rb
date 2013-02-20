require "spec_helper"

describe Tabs::Metrics::Value do

  let(:counter) { Tabs.create_metric("foo", "value") }
  let(:now) { Time.utc(2000, 1, 1, 0, 0) }

  describe ".record" do

    it "sets the expected values for the period" do
      Timecop.freeze(now)
      counter.record(17)
      counter.record(42)
      time = Time.utc(now.year, now.month, now.day, now.hour)
      stats = counter.stats(((now - 2.hours)..(now + 4.hours)), :hour)
      expect(stats).to include({ time => {"count"=>2, "min"=>17, "max"=>42, "sum"=>59, "avg"=>29} })
    end

  end

end
