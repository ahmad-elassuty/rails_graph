# frozen_string_literal: true

module RailsGraph
  module Commands
    class BuildGraph
      def self.call
        classes = ActiveRecord::Base.descendants + RailsGraph.configuration.include_classes

        build_graph(classes)
      end

      def self.build_graph(classes)
        graph = RailsGraph::Graph::Graph.new

        polymorphic_node = RailsGraph::Graph::Nodes::VirtualModel.new("PolymorphicModel")
        graph.add_node(polymorphic_node)

        active_record_base_node = RailsGraph::Graph::Nodes::AbstractModel.new(ActiveRecord::Base)
        graph.add_node(active_record_base_node)

        build_model_nodes(classes, graph)
        build_associations_relationships(classes, graph)
        build_column_nodes(classes, graph) if RailsGraph.configuration.columns?
        build_inheritance_relationships(classes, graph) if RailsGraph.configuration.inheritance?

        graph
      end

      def self.build_model_nodes(classes, graph)
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

      def self.build_column_nodes(classes, graph)
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

      def self.build_inheritance_relationships(classes, graph)
        classes.each do |model|
          identifier = RailsGraph::Helpers::Models.identifier(model)
          node = graph.node(identifier)

          superclass_node_identifier = RailsGraph::Helpers::Models.identifier(model.superclass)
          superclass_node = graph.node(superclass_node_identifier)

          relationship = RailsGraph::Graph::Relationships::Inheritance.new(node, superclass_node)
          graph.add_relationship(relationship)
        end
      end

      def self.build_associations_relationships(classes, graph)
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
