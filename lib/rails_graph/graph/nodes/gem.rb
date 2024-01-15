# frozen_string_literal: true

require_relative "../node"

module RailsGraph
  module Graph
    module Nodes
      class Gem < Node
        attr_reader :specifications

        def initialize(specifications)
          @specifications = specifications

          super(labels: "Gem", name: specifications.name, properties: build_properties)
        end

        def identifier
          "gem_#{name}"
        end

        private

        def build_properties
          {
            description: specifications.description,
            summary: specifications.summary,
            homepage: specifications.homepage,
            version: specifications.version.to_s,
            licenses: specifications.licenses
          }
        end
      end
    end
  end
end
