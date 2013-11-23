module Tabs
  extend self
  extend Tabs::Storage

  class UnknownTypeError < StandardError; end
  class DuplicateMetricError < StandardError; end
  class UnknownMetricError < StandardError; end
  class MetricTypeMismatchError < StandardError; end
  class ResolutionMissingError < StandardError; end

  METRIC_TYPES = ["counter", "value", "task"]

  def configure
    yield(Config)
  end

  def redis
    Config.redis
  end

  def config
    Config
  end

  def increment_counter(key, timestamp=Time.now)
    create_metric(key, "counter") unless metric_exists?(key)
    raise MetricTypeMismatchError.new("Only counter metrics can be incremented") unless metric_type(key) == "counter"
    get_metric(key).increment(timestamp)
  end

  def record_value(key, value, timestamp=Time.now)
    create_metric(key, "value") unless metric_exists?(key)
    raise MetricTypeMismatchError.new("Only value metrics can record a value") unless metric_type(key) == "value"
    get_metric(key).record(value, timestamp)
  end

  def start_task(key, token, timestamp=Time.now)
    create_metric(key, "task")
    raise MetricTypeMismatchError.new("Only task metrics can start a task") unless metric_type(key) == "task"
    get_metric(key).start(token, timestamp)
  end

  def complete_task(key, token, timestamp=Time.now)
    raise MetricTypeMismatchError.new("Only task metrics can complete a task") unless metric_type(key) == "task"
    get_metric(key).complete(token, timestamp)
  end

  def create_metric(key, type)
    raise UnknownTypeError.new("Unknown metric type: #{type}") unless METRIC_TYPES.include?(type)
    raise DuplicateMetricError.new("Metric already exists: #{key}") if metric_exists?(key)
    hset "metrics", key, type
    metric_klass(type).new(key)
  end

  def get_metric(key)
    raise UnknownMetricError.new("Unknown metric: #{key}") unless metric_exists?(key)
    type = hget("metrics", key)
    metric_klass(type).new(key)
  end

  def counter_total(key)
    raise UnknownMetricError.new("Unknown metric: #{key}") unless metric_exists?(key)
    raise MetricTypeMismatchError.new("Only counter metrics can be incremented") unless metric_type(key) == "counter"
    get_metric(key).total
  end

  def get_stats(key, period, resolution)
    raise UnknownMetricError.new("Unknown metric: #{key}") unless metric_exists?(key)
    metric = get_metric(key)
    metric.stats(period, resolution)
  end

  def metric_type(key)
    raise UnknownMetricError.new("Unknown metric: #{key}") unless metric_exists?(key)
    hget "metrics", key
  end

  def list_metrics
    hkeys "metrics"
  end

  def metric_exists?(key)
    list_metrics.include? key
  end

  def drop_metric!(key)
    raise UnknownMetricError.new("Unknown metric: #{key}") unless metric_exists?(key)
    metric = get_metric(key)
    metric.drop!
    hdel "metrics", key
  end

  def drop_all_metrics!
    metrics = self.list_metrics
    metrics.each { |key| self.drop_metric! key }
  end

  def drop_resolution_for_metric!(key, resolution)
    raise UnknownMetricError.new("Unknown metric: #{key}") unless metric_exists?(key)
    raise ResolutionMissingError.new(resolution) unless Tabs::Resolution.all.include? resolution
    metric = get_metric(key)
    metric.drop_by_resolution!(resolution) unless metric_type(key) == "task"
  end

  private

  def metric_klass(type)
    "Tabs::Metrics::#{type.classify}".constantize
  end

end
