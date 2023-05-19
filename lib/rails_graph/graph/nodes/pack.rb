# frozen_string_literal: true

require_relative "../node"

module RailsGraph
  module Graph
    module Nodes
      class Pack < Node
        attr_reader :pack_owner

        def initialize(name, owner)
          @pack_owner = owner

          super(labels: "Pack", name: name, properties: build_properties)
        end

        def identifier
          name
        end

        private

        def build_properties
          { owner: pack_owner }
        end
      end
    end
  end
end
