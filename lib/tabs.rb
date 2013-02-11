require "active_support/all"
require "redis"

require "tabs/version"
require "tabs/config"
require "tabs/storage"

require "tabs/metrics"
require "tabs/metrics/counter"
require "tabs/metrics/value"

module Tabs
  extend self
  extend Tabs::Storage

  def configure
    yield(Config)
  end

  def create(key, type)
    Tabs::Metrics.create(key, type)
  end

  def drop(key)
    Tabs::Metrics.drop(key)
  end

  def metric(key)
    Tabs::Metrics.metric(key)
  end

  def increment(key)
    Tabs::Metrics.increment(key)
  end

  def record(key, value)
    Tabs::Metrics.increment(key)
  end

end
