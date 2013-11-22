require "spec_helper"

describe Tabs::Resolutions::Week do
  let(:timestamp){ Time.utc(2000, 1, 1) }
  let(:beginning_of_week_timestamp){ Time.utc(1999, 12, 27) }

  context "#normalize" do
    it "should roll to the beginning of the week" do
      expect(subject.normalize(timestamp)).to eq(beginning_of_week_timestamp)
    end
  end

  context "#serialize" do
    it "should return YYYY-MM-DD based on beginning of the week" do
      expect(subject.serialize(timestamp)).to eq("1999-12-27")
    end
  end

  context "#deserialize" do
    it "should convert beginning of week string into date" do
      expect(subject.deserialize("1999-12-27")).to eq(beginning_of_week_timestamp)
    end
  end
end
