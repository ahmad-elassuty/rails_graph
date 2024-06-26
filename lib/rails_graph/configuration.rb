# frozen_string_literal: true

module RailsGraph
  class Configuration
    attr_reader :include_classes
    attr_writer :columns, :inheritance, :include_packwerk, :databases, :gems

    def initialize
      @include_classes = []
      @include_packwerk = false
      @databases = true
      @columns = false
      @inheritance = true
      @gems = false
    end

    def include_classes=(include_classes)
      @include_classes = Array(include_classes)
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

    def databases?
      @databases
    end

    def gems?
      @gems
    end
  end
end
