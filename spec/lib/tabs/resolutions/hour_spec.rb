require "spec_helper"

describe Tabs::Resolutions::Hour do
  let(:timestamp){ Time.utc(2000, 1, 1, 14, 12) }

  context "#normalize" do
    it "should normalize the date to year, month, day, hour" do
      expect(subject.normalize(timestamp)).to eq(timestamp.change(min: 0))
    end
  end

  context "#serialize" do
    it "should return YYYY-MM-DD-HH" do
      expect(subject.serialize(timestamp)).to eq("2000-01-01-14")
    end
  end

  context "#deserialize" do
    it "should convert string into date" do
      expect(subject.deserialize("2000-01-01-14")).to eq(timestamp.change(min: 0))
    end
  end
end