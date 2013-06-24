require "spec_helper"

describe Tabs::Metrics::Task::Token do

  describe "#time_elapsed" do

    let(:token) { Tabs::Metrics::Task::Token.new("foo", "bar") }
    let(:time) { Time.now }

    it "should return the time between when the task/token started and completed" do
      token.start(time - 2.days)
      token.complete(time - 1.day)
      expect(token.time_elapsed(:hour)).to eq(24)
    end

  end

end
