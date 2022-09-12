# frozen_string_literal: true

require_relative "base"

module RailsGraph
  module Exporters
    class Cypher < Base
      BASE_CYPHER = "MATCH (n) DETACH DELETE n;"

      def self.export(graph:, filename:)
        queries = build_queries(graph)

        File.write(filename, queries.join("\n"), mode: "w")
      end

      def self.build_queries(graph)
        queries = []
        queries << BASE_CYPHER

        graph.nodes.each { |node| queries << create_node_cypher(node) }
        graph.relationships.each { |relationship| queries << create_relationship_cypher(relationship) }

        queries
      end

      def self.node_ref(node)
        "ref_#{node.id.gsub("-", "_")}"
      end

      def self.format_properties(item)
        output = "name: '#{item.name}'"

        item.properties.each do |k, v|
          formatted_value = case v
                            when String, Symbol then "'#{v}'"
                            when nil then "null"
                            else v.to_s
                            end

          output += ", #{k}: #{formatted_value}"
        end

        output
      end

      def self.create_node_cypher(node)
        ref = node_ref(node)
        labels = node.labels.join(":")
        properties = format_properties(node)

        "CREATE (#{ref}:#{labels} {#{properties}})"
      end

      def self.create_relationship_cypher(relationship)
        source_ref = node_ref(relationship.source)
        target_ref = node_ref(relationship.target)

        "CREATE (#{source_ref})-[:#{relationship.label} {#{format_properties(relationship)}}]->(#{target_ref})"
      end
    end
  end
end
