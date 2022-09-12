# frozen_string_literal: true

module RailsGraph
  module Graph
    class Graph
      def initialize(nodes: {}, relationships: {})
        @nodes = nodes
        @relationships = relationships
      end

      def add_node(node)
        @nodes[node.identifier] = node
      end

      def nodes
        @nodes.values
      end

      def node(identifier)
        @nodes[identifier]
      end

      def add_relationship(relationship)
        @relationships[relationship.identifier] = relationship
      end

      def relationships
        @relationships.values.flatten
      end

      def relationship(identifier)
        @relationships[identifier]
      end

      def as_json(_options = nil)
        {
          nodes: nodes,
          relationships: relationships
        }
      end
    end
  end
end
