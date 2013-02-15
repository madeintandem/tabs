require "spec_helper"

describe Tabs::Metrics::Counter do

  let(:counter) { Tabs.create_metric("foo", "counter") }

  describe ".increment" do

    it "increments the value for the expected periods" do
      counter.increment
      now = Time.now.utc
      time = Time.utc(now.year, now.month, now.day, now.hour)
      stats = counter.stats(((Time.now - 2.hours)..(Time.now + 4.hours)), :hour)
      expect(stats).to include({ time => 1 })
    end
  end

  describe ".stats" do

    let(:now) { Time.utc(2000, 1, 1, 0, 0) }

    before do
      Timecop.freeze(now)
    end

    after do
      Timecop.return
    end

    it "returns the expected results for an hourly counter" do
      counter.increment
      Timecop.freeze(now + 3.hours)
      counter.increment
      Timecop.freeze(now + 6.hours)
      counter.increment
      expect(counter.stats(now..(now + 7.hours), :hour)).to include({ (now + 3.hours) => 1 })
    end

    it "returns the expected results for a daily counter"

    it "returns the expected results for a weekly counter"

    it "returns the expected results for a monthly counter"

    it "returns the expected results for a yearly counter"

  end

end
