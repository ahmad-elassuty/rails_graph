# frozen_string_literal: true

require_relative "../graph/graph"
require_relative "../graph/node"
require_relative "../graph/relationship"

require_relative "../graph/nodes/abstract_model"
require_relative "../graph/nodes/column"
require_relative "../graph/nodes/model"
require_relative "../graph/nodes/pack"
require_relative "../graph/nodes/virtual_model"

require_relative "../graph/relationships/association"
require_relative "../graph/relationships/attribute"
require_relative "../graph/relationships/inheritance"
require_relative "../graph/relationships/pack_dependency"
require_relative "../graph/relationships/pack_model"

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

        build_pack_nodes
        build_pack_dependencies
        build_model_nodes
        build_associations_relationships
        build_column_nodes if configuration.columns?
        build_inheritance_relationships if configuration.inheritance?
        build_pack_model_relationships

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

      def build_pack_nodes
        Packwerk::PackageSet.load_all_from('packs').map do |pack|
          next if pack.name == "."

          name, owner = fetch_pack_attributes(pack)
          node = RailsGraph::Graph::Nodes::Pack.new(name, owner)
          graph.add_node(node)
        end
      end

      def fetch_pack_attributes(pack)
        [
          pack.name,
          pack.config["metadata"]["owner"] || pack.config["metadata"]["stewards"]
        ]
      end

      def build_pack_dependencies
        Packwerk::PackageSet.load_all_from('packs').map do |pack|
          next if pack.name == "."

          source_identifier = pack.name
          source_node = graph.node(source_identifier)

          pack.dependencies.each do |dep|
            target_identifier = dep.gsub('packs/', '')
            target_node = graph.node(target_identifier)

            relationship = RailsGraph::Graph::Relationships::PackDependency.new(source_node, target_node)
            graph.add_relationship(relationship)
          end
        end
      end

      def build_pack_model_relationships
        Packwerk::PackageSet.load_all_from('packs').map do |pack|
          next if pack.name == "." || pack.name == 'goals'

          generic_path = "packs/#{pack.name}/app/models"
          model_classes = Dir["#{generic_path}/**/*.rb"].map do |path|
            path
              .gsub("#{generic_path}", "")
              .gsub(".rb", "")
              .prepend("#{pack.name}")
          end.map(&:camelize).map(&:constantize)

          model_classes.each do |model|
            if model.respond_to?(:descends_from_active_record?)
              source_identifier = RailsGraph::Helpers::Models.identifier(model)
              source_node = graph.node(source_identifier)
              target_identifier = pack.name
              target_node = graph.node(target_identifier)

              relationship = RailsGraph::Graph::Relationships::PackModel.new(source_node, target_node)
              graph.add_relationship(relationship)
            end
          end
        end
      end
    end
  end
end
