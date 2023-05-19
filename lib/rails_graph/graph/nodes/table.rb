# frozen_string_literal: true

require_relative "../node"

module RailsGraph
  module Graph
    module Nodes
      class Table < Node
        attr_reader :name, :database_name

        def initialize(name, database_name)
          @database_name = database_name

          super(labels: "Table", name: name, properties: build_properties)
        end

        def identifier
          "table_#{database_name}.#{name}"
        end

        private

        def build_properties
          {
            database_name: database_name
          }
        end
      end
    end
  end
end
