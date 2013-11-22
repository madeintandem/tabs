module Tabs
  module Resolutionable

    def self.included(base)
      base.extend ClassMethods
    end

    module ClassMethods

      def name
        raise "Must implement #name in the concrete resolution module"
      end

      def serialize
        raise "Must implement #serialize in the concrete resolution module"
      end

      def deserialize
        raise "Must implement #deserialize in the concrete resolution module"
      end

      def from_seconds
        raise "Must implement #from_seconds in the concrete resolution module"
      end

      def to_seconds
        raise "Must implement #to_seconds in the concrete resolution module"
      end

      def add
        raise "Must implement #to_seconds in the concrete resolution module"
      end

      def normalize
        raise "Must implement #normalize in the concrete resolution module"
      end

    end

    def expire(key, timestamp)
      return unless Tabs::Config.expires?(name)
      resolution_ends_at = timestamp.utc.to_i + to_seconds
      expires_at = resolution_ends_at + Tabs::Config.expires_in(name)
      Storage.expireat(key, expires_at)
    end

  end
end
