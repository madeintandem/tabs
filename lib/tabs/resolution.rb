module Tabs
  module Resolution
    extend self

    def register(resolution, klass)
      @@resolution_classes ||= {}
      @@resolution_classes[resolution] = klass
    end

    def serialize(resolution, timestamp)
      resolution_klass(resolution).serialize(timestamp)
    end

    def deserialize(resolution, str)
      resolution_klass(resolution).deserialize(str)
    end

    def from_seconds(resolution, s)
      resolution_klass(resolution).from_seconds(s)
    end

    def normalize(resolution, timestamp)
      resolution_klass(resolution).normalize(timestamp)
    end

    def all
      @@resolution_classes.keys
    end

    private

    def resolution_klass(resolution)
      @@resolution_classes[resolution]
    end

  end
end

Tabs::Resolution.register(:minute, Tabs::Resolutions::Minute)
Tabs::Resolution.register(:hour, Tabs::Resolutions::Hour)
Tabs::Resolution.register(:day, Tabs::Resolutions::Day)
Tabs::Resolution.register(:week, Tabs::Resolutions::Week)
Tabs::Resolution.register(:month, Tabs::Resolutions::Month)
Tabs::Resolution.register(:year, Tabs::Resolutions::Year)
