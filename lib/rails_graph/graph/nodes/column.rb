# frozen_string_literal: true

require_relative "../node"

module RailsGraph
  module Graph
    module Nodes
      class Column < Node
        attr_reader :column

        def initialize(column)
          @column = column

          super(labels: "Column", name: column.name, properties: build_properties)
        end

        private

        def build_properties
          {
            nullable: column.null || false,
            comment: column.comment,
            default: column.default,
            type: column.type,
            sql_type: column.sql_type
          }
        end
      end
    end
  end
end
