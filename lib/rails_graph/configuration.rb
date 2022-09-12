# frozen_string_literal: true

module RailsGraph
  class Configuration
    attr_reader :include_classes

    def initialize
      @include_classes = []
      @columns = false
      @inheritance = true
    end

    def include_classes=(include_classes)
      @include_classes = Array(include_classes)
    end

    def columns?
      @columns
    end

    attr_writer :columns, :inheritance

    def inheritance?
      @inheritance
    end
  end
end
