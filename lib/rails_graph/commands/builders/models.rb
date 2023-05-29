# frozen_string_literal: true

module RailsGraph
  module Commands
    module Builders
      class Models
        attr_reader :graph, :inspector

        def self.enrich(...)
          new(...).enrich
        end

        def enrich
          build_model_nodes
          build_associations
          build_column_nodes if configuration.columns?
          build_model_table_relationships if configuration.databases?
          build_inheritance_relationships if configuration.inheritance?

          inspector.log
          graph
        end

        private

        attr_reader :classes, :configuration

        def initialize(inspector:, graph:, classes:, configuration:)
          @inspector = inspector
          @graph = graph
          @configuration = configuration
          @classes = classes
        end

        def build_model_nodes
          classes.each do |model|
            if model.abstract_class
              node = RailsGraph::Graph::Nodes::AbstractModel.new(model)
              graph.add_node(node)
              next
            end

            node = RailsGraph::Graph::Nodes::Model.new(model)
            graph.add_node(node)
          end
        end

        def build_associations
          Builders::Associations.enrich(inspector: inspector, graph: graph, classes: classes)
        end

        def build_column_nodes
          processed = Hash.new(false)

          classes.each do |model|
            next if model.attribute_names.empty?

            identifier = RailsGraph::Helpers::Models.identifier(model)
            node = graph.node(identifier)

            next if processed[node.id]

            processed[node.id] = true
            add_column_nodes(model: model, node: node)
          end
        end

        def build_inheritance_relationships
          classes.each do |model|
            identifier = RailsGraph::Helpers::Models.identifier(model)
            node = graph.node(identifier)

            superclass_node_identifier = RailsGraph::Helpers::Models.identifier(model.superclass)
            superclass_node = graph.node(superclass_node_identifier)

            relationship = RailsGraph::Graph::Relationships::Inheritance.new(node, superclass_node)
            graph.add_relationship(relationship)
          end
        end

        def build_model_table_relationships
          classes.each do |model|
            database_name = model.connection_pool.db_config.name
            table_node = graph.node("table_#{database_name}.#{model.table_name}")

            next unless table_node

            identifier = RailsGraph::Helpers::Models.identifier(model)
            node = graph.node(identifier)

            relationship = build_represents_table_relationship(node, table_node)
            graph.add_relationship(relationship)
          end
        end

        def build_represents_table_relationship(model, table)
          RailsGraph::Graph::Relationship.new(
            source: model,
            target: table,
            label: "RepresentsTable",
            name: "represents_table",
            properties: {}
          )
        end

        def add_column_nodes(model:, node:)
          model.columns.each do |column|
            column_node = RailsGraph::Graph::Nodes::Column.new(column)
            graph.add_node(column_node)

            relationship = RailsGraph::Graph::Relationships::Attribute.new(node, column_node)
            graph.add_relationship(relationship)
          end
        end
      end
    end
  end
end
