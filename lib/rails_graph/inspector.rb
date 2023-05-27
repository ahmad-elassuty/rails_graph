# frozen_string_literal: true

require "set"

module RailsGraph
  class Inspector
    def initialize
      @classes = Set.new
      @associations = Set.new
    end

    def add_class(klass)
      @classes.add(klass)
    end

    def add_association(association)
      @associations.add(association)
    end

    def log
      @classes.each do |klass|
        puts "[WARN][RailsGraph]: Invalid class configuration: #{klass}"
      end

      @associations.each do |association|
        puts "[WARN][RailsGraph]: #{association.name} association defined " \
             "under #{association.active_record.name} class has invalid configurations!"
      end
    end
  end
end
