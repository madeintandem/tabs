require "rubygems"
require "tabs"
require "pry"
require "timecop"

RSpec.configure do |config|
  config.mock_with :rspec

  config.before(:each) do
  	Tabs::Resolution.register_default_resolutions
    Tabs::Storage.del_by_prefix("")
  end
end
