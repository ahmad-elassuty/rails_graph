# frozen_string_literal: true

require_relative "../node"

module RailsGraph
  module Graph
    module Nodes
      class Pack < Node
        attr_reader :pack_name, :pack_owner

        def initialize(name, owner)
          @pack_name = name
          @pack_owner = owner

          super(labels: "Pack", name: pack_name, properties: build_properties)
        end

        def identifier
          pack_name
        end

        private

        def build_properties
          {
            name: pack_name,
            owner: pack_owner
          }
        end
      end
    end
  end
end
