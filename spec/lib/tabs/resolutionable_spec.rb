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
    let(:expires_setting){ 1.day }

    before do
      Tabs::Config.register_resolution(:test, TestResolution)
      Tabs::Config.set_expirations(test: expires_setting)
    end

    after do
      Tabs::Config.reset_expirations
      Tabs::Config.unregister_resolutions(:test)
    end

    it "sets the expiration for the given key" do
      now = Time.utc(2050, 1, 1, 0, 0)
      Tabs::Storage.set("foo", "bar")
      TestResolution.expire("foo", now)
      expire_date = Time.now + Tabs::Storage.ttl("foo")
      expect(now + expires_setting).to eq expire_date.utc.change(hour: 0)
    end

  end

end
