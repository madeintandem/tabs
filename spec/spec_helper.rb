require "rubygems"
require "tabs"
require "fakeredis/rspec"
require "pry"
require "timecop"

RSpec.configure do |config|
  config.mock_with :rspec

  config.before(:each) do
  	Tabs::Resolution.register_default_resolutions
  end
end
