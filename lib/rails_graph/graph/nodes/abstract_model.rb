# frozen_string_literal: true

require_relative "../node"

module RailsGraph
  module Graph
    module Nodes
      class AbstractModel < Node
        attr_reader :model

        def initialize(model)
          @model = model

          super(
            labels: "AbstractModel",
            name: model.name,
            properties: {}
          )
        end

        def identifier
          RailsGraph::Helpers::Models.identifier(model)
        end
      end
    end
  end
end
