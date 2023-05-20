# frozen_string_literal: true

module RailsGraph
  module Commands
    module Builders
      class Databases
        def self.enrich(graph:)
          new(graph: graph).enrich

          graph
        end

        def enrich
          build_databases_nodes
          build_tables_nodes
        end

        private

        attr_reader :graph

        def initialize(graph:)
          @graph = graph
        end

        def build_databases_nodes
          databases.each do |config|
            node = RailsGraph::Graph::Nodes::Database.new(config)
            graph.add_node(node)
          end
        end

        def build_tables_nodes
          ActiveRecord::Base.connection_handler.connection_pools.each do |connection_pool|
            database_name = connection_pool.db_config.name
            database_node = graph.node("database_#{database_name}")

            connection_pool.connection.tables.each do |table|
              table_node = RailsGraph::Graph::Nodes::Table.new(table, database_name)
              graph.add_node(table_node)

              add_persisted_in_relationship(table_node, database_node)
            end
          end
        end

        def add_persisted_in_relationship(table_node, database_node)
          relationship = RailsGraph::Graph::Relationship.new(
            source: table_node,
            target: database_node,
            label: "PersistedIn",
            name: "persisted_in",
            properties: {}
          )

          graph.add_relationship(relationship)
        end

        def databases
          @databases ||= ActiveRecord::Base.configurations.configs_for(env_name: Rails.env)
        end
      end
    end
  end
end
