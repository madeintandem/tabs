module Tabs
  extend self
  extend Tabs::Storage

  class UnknownTypeError < Exception; end
  class DuplicateMetricError < Exception; end
  class UnknownMetricError < Exception; end
  class MetricTypeMismatchError < Exception; end

  METRIC_TYPES = ["counter", "value"]

  RESOLUTIONS = [:minute, :hour, :day, :week, :month, :year]

  def configure
    yield(Config)
  end

  def redis
    Config.redis
  end

  def increment_counter(key)
    raise UnknownMetricError.new("Unknown metric: #{key}") unless metric_exists?(key)
    raise MetricTypeMismatchError.new("Only counter metrics can be incremented") unless metric_type(key) == "counter"
    get_metric(key).increment
  end

  def record_value(key, value)
    raise UnknownMetricError.new("Unknown metric: #{key}") unless metric_exists?(key)
    raise MetricTypeMismatchError.new("Only value metrics can record a value") unless metric_type(key) == "value"
    get_metric(key).record(value)
  end

  def create_metric(key, type)
    raise UnknownTypeError.new("Unknown metric type: #{type}") unless METRIC_TYPES.include?(type)
    raise DuplicateMetricError.new("Metric already exists: #{key}") if metric_exists?(key)
    hset "metrics", key, type
    metric_klass(type).new(key)
  end

  def get_metric(key)
    metrics = get("metrics")
    type = metrics[key]
    metric_klass(type).new(key)
  end

  def metric_type(key)
    hget "metrics", key
  end

  def drop_metric(key)
    hdel "metrics", key
    # TODO: Need to finish this
  end

  def list_metrics
    hkeys "metrics"
  end

  def metric_exists?(key)
    list_metrics.include? key
  end

  private

  def metric_klass(type)
    "Tabs::Metrics::#{type.classify}".constantize
  end

end
