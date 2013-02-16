require "spec_helper"

describe Tabs::Metrics::Counter do

  let(:counter) { Tabs.create_metric("foo", "counter") }
  let(:now) { Time.utc(2000, 1, 1, 0, 0) }

  describe ".increment" do

    it "increments the value for the expected periods" do
      Timecop.freeze(now)
      counter.increment
      time = Time.utc(now.year, now.month, now.day, now.hour)
      stats = counter.stats(((now - 2.hours)..(now + 4.hours)), :hour)
      expect(stats).to include({ time => 1 })
    end
  end

  describe ".stats" do

    before do
      Timecop.freeze(now)
    end

    after do
      Timecop.return
    end

    def create_span(time_unit)
      counter.increment
      Timecop.freeze(now + 3.send(time_unit))
      counter.increment
      Timecop.freeze(now + 6.send(time_unit))
      counter.increment
      Timecop.freeze(now)
    end

    it "returns the expected results for an hourly counter" do
      create_span(:hours)
      expect(counter.stats(now..(now + 7.hours), :hour)).to include({ (now + 3.hours) => 1 })
    end

    it "returns the expected results for a daily counter" do
      create_span(:days)
      expect(counter.stats(now..(now + 7.days), :day)).to include({ (now + 3.days) => 1 })
    end

    it "returns the expected results for a weekly counter" do
      create_span(:weeks)
      target_date = (now + 3.weeks).beginning_of_week
      expect(counter.stats(now..(now + 7.weeks), :week)).to include({ target_date => 1 })
    end

    it "returns the expected results for a monthly counter" do
      create_span(:months)
      expect(counter.stats(now..(now + 7.months), :month)).to include({ (now + 3.months) => 1 })
    end

    it "returns the expected results for a yearly counter" do
      create_span(:years)
      expect(counter.stats(now..(now + 7.years), :year)).to include({ (now + 3.years) => 1 })
    end

  end

end
