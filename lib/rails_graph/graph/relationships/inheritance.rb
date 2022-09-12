# frozen_string_literal: true

require_relative "../relationship"

module RailsGraph
  module Graph
    module Relationships
      class Inheritance < Relationship
        def initialize(source, target)
          super(
            source: source,
            target: target,
            label: "InheritsFrom",
            name: target.name,
            properties: {}
          )
        end
      end
    end
  end
end
