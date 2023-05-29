# frozen_string_literal: true

module RailsGraph
  module Commands
    module Builders
      class Associations
        attr_reader :graph, :inspector

        def self.enrich(...)
          new(...).enrich
        end

        def enrich
          build_associations_relationships
        end

        private

        attr_reader :classes

        def initialize(inspector:, graph:, classes:)
          @inspector = inspector
          @graph = graph
          @classes = classes
        end

        def build_associations_relationships
          classes.each do |model|
            model.reflect_on_all_associations.each do |association|
              association.check_validity!

              source_node, target_node = fetch_association_nodes(graph, association)
              next report_invalid_class(model) if source_node.nil? || target_node.nil?

              add_relationship(association, source_node, target_node)
            rescue ActiveRecord::ActiveRecordError => _e
              report_invalid_association(association)
            end
          end
        end

        def fetch_association_nodes(graph, association)
          source_node = RailsGraph::Helpers::Associations.source_node(graph, association)
          target_node = RailsGraph::Helpers::Associations.target_node(graph, association)
          [source_node, target_node]
        end

        def add_relationship(association, source_node, target_node)
          relationship = RailsGraph::Graph::Relationships::Association.new(association, source_node, target_node)
          graph.add_relationship(relationship)
        end

        def report_invalid_association(association)
          inspector.add_association(association)
        end

        def report_invalid_class(klass)
          inspector.add_class(klass)
        end
      end
    end
  end
end
