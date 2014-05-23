module Tabs
  module Config
    extend self

    attr_accessor :negative_metric

    @negative_metric = false

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

    def prefix=(arg)
      @prefix = arg
    end

    def prefix
      @prefix
    end

    def register_resolution(klass)
      Tabs::Resolution.register(klass)
    end

    def unregister_resolutions(*resolutions)
      Tabs::Resolution.unregister(resolutions)
    end

    def expiration_settings
      @expiration_settings ||= {}
    end

    def set_expirations(resolution_hash)
      resolution_hash.each do |resolution, expires_in_seconds|
        raise Tabs::ResolutionMissingError.new(resolution) unless Tabs::Resolution.all.include? resolution
        expiration_settings[resolution] = expires_in_seconds
      end
    end

    def expires?(resolution)
      expiration_settings.has_key?(resolution)
    end

    def expires_in(resolution)
      expiration_settings[resolution]
    end

    def reset_expirations
      @expiration_settings = {}
    end

  end
end
