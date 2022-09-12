# frozen_string_literal: true

require_relative "../node"

module RailsGraph
  module Graph
    module Nodes
      class Model < Node
        attr_reader :model

        def initialize(model)
          @model = model

          super(labels: "Model", name: model.name, properties: build_properties)
        end

        def identifier
          RailsGraph::Helpers::Models.identifier(model)
        end

        private

        def build_properties
          {
            table_name: model.table_name,
            table_exists: table_exists?,
            columns_count: model.attribute_names.count,
            db_indexes_count: db_indexes_count,
            primary_key: model.primary_key,
            full_name: model.to_s
          }
        end

        def table_exists?
          ActiveRecord::Base.connection.table_exists?(model.table_name)
        end

        def db_indexes_count
          ActiveRecord::Base.connection.indexes(model.table_name).count
        end
      end
    end
  end
end
