module Tabs
  module Resolution
    extend self

    def serialize(resolution, timestamp)
      resolution_klass(resolution).serialize(timestamp)
    end

    def deserialize(resolution, str)
      resolution_klass(resolution).deserialize(str)
    end

    def normalize(resolution, timestamp)
      resolution_klass(resolution).normalize(timestamp)
    end

    private

    def resolution_klass(resolution)
      "Tabs::Resolutions::#{resolution.to_s.classify}".constantize
    end

  end
end
