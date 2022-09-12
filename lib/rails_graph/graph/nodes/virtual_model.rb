# frozen_string_literal: true

require_relative "../node"

module RailsGraph
  module Graph
    module Nodes
      class VirtualModel < Node
        def initialize(name)
          super(
            labels: "VirtualModel",
            name: name,
            properties: {}
          )
        end

        def identifier
          name
        end
      end
    end
  end
end
