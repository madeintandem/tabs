module Tabs
  extend self
  extend Tabs::Storage

  class UnknownTypeError < StandardError; end
  class DuplicateMetricError < StandardError; end
  class UnknownMetricError < StandardError; end
  class MetricTypeMismatchError < StandardError; end
  class ResolutionMissingError < StandardError; end

  METRIC_TYPES = ["counter", "value", "task"]
  FIND_OR_CREATE_MUTEX = Mutex.new
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
    get_or_create_metric(key,"counter").increment(timestamp)
  end

  def record_value(key, value, timestamp=Time.now)
    get_or_create_metric(key,"value").record(value, timestamp)
  end

  def start_task(key, token, timestamp=Time.now)
    get_or_create_metric(key,"task").start(token, timestamp)
  end

  def complete_task(key, token, timestamp=Time.now)
    get_metric(key,"task").complete(token, timestamp)
  end

  def get_or_create_metric(key,type)
    FIND_OR_CREATE_MUTEX.synchronize do
      if metric_exists?(key)
        return get_metric(key,type)
      else
        return create_metric(key,type)
      end
    end
  end

  def create_metric(key, type)
    raise UnknownTypeError.new("Unknown metric type: #{type}") unless METRIC_TYPES.include?(type)
    raise DuplicateMetricError.new("Metric already exists: #{key}") if metric_exists?(key)
    hset "metrics", key, type
    metric_klass(type).new(key)
  end

  def get_metric(key,type=nil)
    raise UnknownMetricError.new("Unknown metric: #{key}") unless metric_exists?(key)
    raise MetricTypeMismatchError.new("Metric types do not match") unless type.blank? || metric_type(key) == type
    type = hget("metrics", key)
    metric_klass(type).new(key)
  end

  def counter_total(key)
    unless metric_exists?(key)
      if block_given?
        return yield
      else
        raise UnknownMetricError.new("Unknown metric: #{key}")
      end
    end
    get_metric(key,"counter").total
  end

  def get_stats(key, period, resolution)
    metric = get_metric(key)
    metric.stats(period, resolution)
  end

  def metric_type(key)
    hget("metrics", key) or (raise UnknownMetricError.new("Unknown metric: #{key}"))
  end

  def list_metrics
    hkeys "metrics"
  end

  def metric_exists?(key)
    list_metrics.include? key
  end

  def drop_metric!(key)
    metric = get_metric(key)
    metric.drop!
    hdel "metrics", key
  end

  def drop_all_metrics!
    metrics = self.list_metrics
    metrics.each { |key| self.drop_metric! key }
  end

  def drop_resolution_for_metric!(key, resolution)
    raise ResolutionMissingError.new(resolution) unless Tabs::Resolution.all.include? resolution
    metric = get_metric(key)
    metric.drop_by_resolution!(resolution) unless metric_type(key) == "task"
  end

  private

  def metric_klass(type)
    "Tabs::Metrics::#{type.classify}".constantize
  end

end
