# frozen_string_literal: true

require_relative "../graph/graph"
require_relative "../graph/node"
require_relative "../graph/relationship"

require_relative "../graph/nodes/abstract_model"
require_relative "../graph/nodes/column"
require_relative "../graph/nodes/database"
require_relative "../graph/nodes/gem"
require_relative "../graph/nodes/model"
require_relative "../graph/nodes/pack"
require_relative "../graph/nodes/table"
require_relative "../graph/nodes/virtual_model"

require_relative "../graph/relationships/association"
require_relative "../graph/relationships/attribute"
require_relative "../graph/relationships/inheritance"
require_relative "../graph/relationships/pack_dependency"
require_relative "../graph/relationships/pack_model"

require_relative "../helpers/associations"
require_relative "../helpers/models"

require_relative "./builders/associations"
require_relative "./builders/models"
require_relative "./builders/packs"
require_relative "./builders/databases"
require_relative "./builders/gems_builder"

module RailsGraph
  module Commands
    class BuildGraph
      def self.call(configuration:)
        new(configuration: configuration).call
      end

      def call
        setup_generic_nodes

        RailsGraph::Commands::Builders::GemsBuilder.enrich(graph: graph, configuration: configuration)
        RailsGraph::Commands::Builders::Databases.enrich(graph: graph, configuration: configuration)
        RailsGraph::Commands::Builders::Models.enrich(inspector: inspector, graph: graph, classes: classes,
                                                      configuration: configuration)
        RailsGraph::Commands::Builders::Packs.enrich(graph: graph, configuration: configuration)

        graph
      end

      private

      attr_reader :configuration, :classes, :graph, :inspector

      def initialize(configuration:)
        @configuration = configuration
        @classes = ActiveRecord::Base.descendants + configuration.include_classes
        @graph = RailsGraph::Graph::Graph.new
        @inspector = RailsGraph::Inspector.new
      end

      def setup_generic_nodes
        polymorphic_node = RailsGraph::Graph::Nodes::VirtualModel.new("PolymorphicModel")
        graph.add_node(polymorphic_node)

        active_record_base_node = RailsGraph::Graph::Nodes::AbstractModel.new(ActiveRecord::Base)
        graph.add_node(active_record_base_node)
      end
    end
  end
end
