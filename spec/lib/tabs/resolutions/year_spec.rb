require "spec_helper"

describe Tabs::Resolutions::Year do
  let(:timestamp){ Time.utc(2000, 2) }

  context "#normalize" do
    it "should normalize the date to year, month" do
      expect(subject.normalize(timestamp)).to eq(timestamp.change(month: 1))
    end
  end

  context "#serialize" do
    it "should return YYYY" do
      expect(subject.serialize(timestamp)).to eq("2000")
    end
  end

  context "#deserialize" do
    it "should convert string into date" do
      expect(subject.deserialize("2000")).to eq(timestamp.change(month: 1))
    end
  end
end