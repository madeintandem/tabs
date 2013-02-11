module Tabs
  module Metrics
    extend self
    extend Tabs::Storage

    class UnknownTypeError < Exception; end
    class DuplicateMetricError < Exception; end

    TYPES = ["counter", "value"]

    def redis
      @redis ||= Config.redis
    end

    def get_metric(key)
      metrics = get("metrics")
      type = metrics.find { |m| m.key == key }
      metric_klass(type).new(key)
    end

    def create(key, type)
      raise UnknownTypeError.new("Unkown metric type: #{type}") unless TYPES.include?(type)
      raise DuplicateMetricError.new("Metric already exists: #{key}") if exists?(key)
      hset "metrics", key, type
      metric_klass(type).new(key)
    end

    def list
      hkeys "metrics"
    end

    def exists?(key)
      list.include? key
    end

    private

    def metric_klass(type)
      "Tabs::Metrics::#{type.classify}".constantize
    end

  end
end
