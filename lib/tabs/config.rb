module Tabs
  module Config
    extend self

    def decimal_precision
      @decimal_precision ||= 5
    end

    def decimal_precision=(precision)
      @decimal_precision = precision
    end

    def redis=(arg)
      if arg.is_a?(Redis)
        @redis = arg
      else
        @redis = Redis.new(arg)
      end
    end

    def redis
      @redis ||= Redis.new
    end

    def register_resolution(resolution, klass)
      Tabs::Resolution.register(resolution, klass)
    end

  end
end
