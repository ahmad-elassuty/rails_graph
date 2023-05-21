# frozen_string_literal: true

module RailsGraph
  module Commands
    module Builders
      class Packs
        def self.enrich(graph:, configuration:)
          return unless configuration.include_packwerk?

          new(graph: graph).enrich

          graph
        end

        def enrich
          build_pack_nodes
          build_pack_relationships
          build_pack_model_relationships
        end

        private

        attr_reader :graph

        def initialize(graph:)
          @graph = graph
        end

        def build_pack_nodes
          packs.each do |pack|
            name, owner = fetch_pack_attributes(pack)
            node = RailsGraph::Graph::Nodes::Pack.new(name, owner)
            graph.add_node(node)
          end
        end

        def build_pack_relationships
          packs.each do |pack|
            source_identifier = pack.name
            source_node = graph.node(source_identifier)

            pack.dependencies.each do |dep|
              target_identifier = dep.gsub("packs/", "")
              target_node = graph.node(target_identifier)

              relationship = RailsGraph::Graph::Relationships::PackDependency.new(source_node, target_node)
              graph.add_relationship(relationship)
            end
          end
        end

        def build_pack_model_relationships
          packs.each do |pack|
            next if pack.name == "goals"

            models = fetch_pack_models(pack: pack)
            models.each do |model|
              add_model_relationship(pack: pack, model: model)
            end
          end
        end

        def packs
          @packs ||=
            Packwerk::PackageSet.load_all_from("packs").reject do |pack|
              pack.name == "."
            end
        end

        def fetch_pack_attributes(pack)
          [
            pack.name,
            pack.config["metadata"]["owner"] || pack.config["metadata"]["stewards"]
          ]
        end

        def fetch_pack_models(pack:)
          generic_path = "packs/#{pack.name}/app/models"
          Dir["#{generic_path}/**/*.rb"].map do |path|
            path
              .gsub(generic_path, "")
              .gsub(".rb", "")
              .prepend(pack.name)
              .camelize
              .constantize
          end
        end

        def add_model_relationship(pack:, model:)
          return unless model.respond_to?(:descends_from_active_record?)

          source_identifier = RailsGraph::Helpers::Models.identifier(model)
          target_identifier = pack.name

          source_node = graph.node(source_identifier)
          target_node = graph.node(target_identifier)

          relationship = RailsGraph::Graph::Relationships::PackModel.new(source_node, target_node)
          graph.add_relationship(relationship)
        end
      end
    end
  end
end
