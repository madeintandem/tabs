require "rubygems"
require "tabs"
require "fakeredis/rspec"
require "pry"
require "timecop"

RSpec.configure do |config|
  config.mock_with :rspec
end
