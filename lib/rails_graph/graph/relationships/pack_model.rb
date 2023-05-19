# frozen_string_literal: true

require_relative "../relationship"

module RailsGraph
  module Graph
    module Relationships
      class PackModel < Relationship
        def initialize(source, target)
          super(
            source: source,
            target: target,
            label: "PartOfPack",
            name: target.name
          )
        end
      end
    end
  end
end
