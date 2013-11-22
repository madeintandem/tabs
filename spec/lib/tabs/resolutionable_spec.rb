require "spec_helper"

describe Tabs::Resolutionable do

  module TestResolution
    include Tabs::Resolutionable
    extend self

    def name
      :test
    end

    def to_seconds
      1000
    end

  end

  describe "interface exceptions" do

    ["serialize", "deserialize", "from_seconds", "add", "normalize"].each do |method|
      it "are raised when the #{method} method is not implemented" do
        expect { TestResolution.send(method) }.to raise_error
      end
    end

  end

  describe "#expire" do

    before do
      Tabs::Config.register_resolution(:test, TestResolution)
      Tabs::Config.set_expirations(test: 1.day)
    end

    after do
      Tabs::Config.reset_expirations
      Tabs::Config.unregister_resolutions(:test)
    end

    it "sets the expiration for the given key" do
      now = Time.new(2050, 1, 1, 0, 0)
      Tabs::Storage.set("foo", "bar")
      TestResolution.expire("foo", now)
      expect(Tabs::Storage.ttl("foo")).to eq 1578032200
    end

  end

end
