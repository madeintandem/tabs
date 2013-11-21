module Tabs
  module Resolutionable
    extend self

    def serialize
      raise "Must implement serialize in the concrete resolution module"
    end

    def deserialize
      raise "Must implement deserialize in the concrete resolution module"
    end

    def from_seconds
      raise "Must implement from_seconds in the concrete resolution module"
    end

    def add
      raise "Must implement to_seconds in the concrete resolution module"
    end

    def normalize
      raise "Must implement normalize in the concrete resolution module"
    end

    def expire(key, timestamp)
      return unless expires?
      Storage.expire_at(key, timestamp + to_seconds + expires_in)
    end

  end
end
