# frozen_string_literal: true

require_relative "../graph/graph"
require_relative "../graph/node"
require_relative "../graph/relationship"

require_relative "../graph/nodes/abstract_model"
require_relative "../graph/nodes/column"
require_relative "../graph/nodes/model"
require_relative "../graph/nodes/virtual_model"

require_relative "../graph/relationships/association"
require_relative "../graph/relationships/attribute"
require_relative "../graph/relationships/inheritance"

require_relative "../helpers/associations"
require_relative "../helpers/models"

module RailsGraph
  module Commands
    class BuildGraph
      def self.call(configuration:)
        new(configuration: configuration).call
      end

      def call
        polymorphic_node = RailsGraph::Graph::Nodes::VirtualModel.new("PolymorphicModel")
        graph.add_node(polymorphic_node)

        active_record_base_node = RailsGraph::Graph::Nodes::AbstractModel.new(ActiveRecord::Base)
        graph.add_node(active_record_base_node)

        build_model_nodes
        build_associations_relationships
        build_column_nodes if configuration.columns?
        build_inheritance_relationships if configuration.inheritance?

        graph
      end

      private

      attr_reader :configuration, :classes, :graph

      def initialize(configuration:)
        @configuration = configuration
        @classes = ActiveRecord::Base.descendants + configuration.include_classes
        @graph = RailsGraph::Graph::Graph.new
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

      def build_column_nodes
        processed = Hash.new(false)

        classes.each do |model|
          next if model.attribute_names.empty?

          identifier = RailsGraph::Helpers::Models.identifier(model)
          node = graph.node(identifier)

          next if processed[node.id]

          processed[node.id] = true

          model.columns.each do |column|
            column_node = RailsGraph::Graph::Nodes::Column.new(column)
            graph.add_node(column_node)

            relationship = RailsGraph::Graph::Relationships::Attribute.new(node, column_node)
            graph.add_relationship(relationship)
          end
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

      def build_associations_relationships
        classes.each do |model|
          model.reflect_on_all_associations.each do |association|
            source_node = RailsGraph::Helpers::Associations.source_node(graph, association)
            target_node = RailsGraph::Helpers::Associations.target_node(graph, association)

            relationship = RailsGraph::Graph::Relationships::Association.new(association, source_node, target_node)
            graph.add_relationship(relationship)
          end
        end
      end
    end
  end
end
