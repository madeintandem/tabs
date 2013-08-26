module Tabs
  module Resolutionable
    extend self

    class MethodNotImplementedException < Exception; end

    def serialize
      raise MethodNotImplementedException
    end

    def deserialize
      raise MethodNotImplementedException
    end

    def from_seconds
      raise MethodNotImplementedException
    end

    def normalize
      raise MethodNotImplementedException
    end
  end
end
