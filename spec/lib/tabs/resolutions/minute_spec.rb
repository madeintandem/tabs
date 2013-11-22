require "spec_helper"

describe Tabs::Resolutions::Minute do
  let(:timestamp){ Time.utc(2000, 1, 1, 14, 12, 44) }

  context "#normalize" do
    it "should normalize the date to year, month, day, hour, minute" do
      expect(subject.normalize(timestamp)).to eq(timestamp.change(sec: 0))
    end
  end

  context "#serialize" do
    it "should return YYYY-MM-DD-HH-MM" do
      expect(subject.serialize(timestamp)).to eq("2000-01-01-14-12")
    end
  end

  context "#deserialize" do
    it "should convert string into date" do
      expect(subject.deserialize("2000-01-01-14-12")).to eq(timestamp.change(sec: 0))
    end
  end
end