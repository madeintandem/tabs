require "spec_helper"

describe Tabs::Resolutions::Day do
  let(:timestamp){ Time.new(2000, 1, 1, 12, 15) }

  context "#normalize" do
    it "should normalize the date to year, month, day" do
      expect(subject.normalize(timestamp)).to eq(timestamp.utc.change(hour: 0))
    end
  end

  context "#serialize" do
    it "should return YYYY-MM-DD" do
      expect(subject.serialize(timestamp)).to eq("2000-01-01")
    end
  end

  context "#deserialize" do
    it "should convert string into date" do
      expect(subject.deserialize("2000-01-01")).to eq(timestamp.utc.change(hour: 0))
    end
  end
end