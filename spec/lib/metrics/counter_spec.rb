require "spec_helper"

describe Tabs::Metrics::Counter do

  describe ".increment" do

    it "increments the value for the expected periods" do
      counter = Tabs.create_metric("foo", "counter")
      counter.increment
      stats = counter.stats(((Time.now - 2.hours)..(Time.now + 4.hours)), :hour)
      binding.pry
    end
  end


  describe ".stats" do

  end

end
