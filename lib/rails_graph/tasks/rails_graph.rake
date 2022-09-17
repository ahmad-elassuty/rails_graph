# frozen_string_literal: true

require_relative "../helpers/options_parser"

namespace :rails_graph do
  include RailsGraph::Helpers::OptionsParser

  namespace :export do
    desc "Export graph to Neo4j graph database"
    task neo4j: :environment do
      options = parse_options(
        "Usage: rails rails_graph:export:neo4j [options]",
        [
          ["-h", "--host HOST", "Neo4j host, e.g neo4j://localhost:7687"],
          ["-u", "--username USERNAME", "Neo4j username"],
          ["-p", "--password PASSWORD", "Neo4j password"]
        ]
      )

      RailsGraph.load_entities
      graph = RailsGraph.build_graph
      RailsGraph.export_graph(graph: graph, format: :neo4j, **options)

      exit
    end
  end
end
