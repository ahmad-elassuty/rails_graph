# frozen_string_literal: true

require_relative "base"
require "neo4j_ruby_driver"

module RailsGraph
  module Exporters
    class Neo4j < Base
      def self.export(graph:, host:, username:, password:)
        auth = ::Neo4j::Driver::AuthTokens.basic(username, password)

        ::Neo4j::Driver::GraphDatabase.driver(host, auth) do |driver|
          driver.session do |session|
            queries = build_query(graph)

            session.write_transaction do |tx|
              tx.run(queries, message: "Success!")
            end
          end
        end
      end

      def self.build_query(graph)
        queries = Cypher.build_queries(graph)
        queries.shift
        queries.join("\n")
      end
    end
  end
end
