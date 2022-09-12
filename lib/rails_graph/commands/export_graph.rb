# frozen_string_literal: true

require_relative "../exporters/cypher"
require_relative "../exporters/json"
require_relative "../exporters/neo4j"

module RailsGraph
  module Commands
    class ExportGraph
      EXPORTERS = {
        cypher: RailsGraph::Exporters::Cypher,
        json: RailsGraph::Exporters::Json,
        neo4j: RailsGraph::Exporters::Neo4j
      }.freeze

      def self.call(graph:, format: :cypher, **options)
        EXPORTERS[format].export(graph: graph, **options)
      end
    end
  end
end
