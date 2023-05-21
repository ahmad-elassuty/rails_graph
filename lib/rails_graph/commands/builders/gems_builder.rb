# frozen_string_literal: true

module RailsGraph
  module Commands
    module Builders
      class GemsBuilder
        def self.enrich(graph:, configuration:)
          return unless configuration.gems?

          new(graph: graph).enrich

          graph
        end

        def enrich
          build_gems_nodes

          gems.each do |specifications|
            source_node = graph.node("gem_#{specifications.name}")

            # build_authored_by_relationships(specifications, source_node)
            build_depends_on_gem_relationships(specifications, source_node)
          end
        end

        private

        attr_reader :graph

        def initialize(graph:)
          @graph = graph
        end

        def build_gems_nodes
          gems.each do |gem|
            node = RailsGraph::Graph::Nodes::Gem.new(gem)
            graph.add_node(node)
          end
        end

        # def build_authored_by_relationships(specifications); end

        def build_depends_on_gem_relationships(specifications, source_node)
          specifications.dependencies.each do |dependency|
            target_node = graph.node("gem_#{dependency.name}")
            add_depends_on_gem_relationship(source_node, target_node, dependency)
          end
        end

        def add_depends_on_gem_relationship(source_node, target_node, dependency)
          relationship = RailsGraph::Graph::Relationship.new(
            source: source_node,
            target: target_node,
            label: "DependsOnGem",
            name: "depends_on_gem",
            properties: { type: dependency.type, requirement: dependency.requirement.to_s }
          )

          graph.add_relationship(relationship)
        end

        def gems
          @gems ||= Gem::Specification.all
        end
      end
    end
  end
end
