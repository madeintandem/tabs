require "tabs/version"
require "tabs/config"

module Tabs
  extend self

  METRIC_TYPES = ["counter", "value"]

  def redis
    @redis ||= config.redis
  end

  def config
    Config
  end

  def configure
    yield(config)
  end

  def create_metric(key, type)
    raise "Unkown metric type: #{type}" unless METRIC_TYPES.include?(type)
    true
  end

  def increment(key)
    true
  end

  def record(key, value)
    true
  end

  def get_values(key)
    []
  end

end
