# frozen_string_literal: true

module RailsGraph
  class Configuration
    attr_reader :include_classes
    attr_reader :include_packwerk
    attr_writer :columns, :inheritance

    def initialize
      @include_classes = []
      @include_packwerk = false
      @columns = false
      @inheritance = true
    end

    def include_classes=(include_classes)
      @include_classes = Array(include_classes)
    end

    def include_packwerk=(include_packwerk)
      @include_packwerk = include_packwerk
    end

    def columns?
      @columns
    end

    def inheritance?
      @inheritance
    end

    def include_packwerk?
      @include_packwerk
    end
  end
end
