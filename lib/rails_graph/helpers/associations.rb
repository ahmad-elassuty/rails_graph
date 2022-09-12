# frozen_string_literal: true

module RailsGraph
  module Helpers
    module Associations
      module_function

      def source_identifier(association)
        RailsGraph::Helpers::Models.identifier(association.active_record)
      end

      def source_node(graph, association)
        identifier = source_identifier(association)

        graph.node(identifier)
      end

      def target_identifier(association)
        return "PolymorphicModel" if association.polymorphic?

        RailsGraph::Helpers::Models.identifier(association.klass)
      end

      def target_node(graph, association)
        identifier = target_identifier(association)

        graph.node(identifier)
      end
    end
  end
end
