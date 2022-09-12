# frozen_string_literal: true

require_relative "../relationship"

module RailsGraph
  module Graph
    module Relationships
      class Attribute < Relationship
        def initialize(source, target)
          super(
            source: source,
            target: target,
            label: "HasAttribute",
            name: target.name,
            properties: {
              primary_key: source.properties[:primary_key] == target.name
            }
          )
        end
      end
    end
  end
end
