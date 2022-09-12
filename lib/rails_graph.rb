# frozen_string_literal: true

require_relative "rails_graph/version"
require_relative "rails_graph/configuration"

require_relative "rails_graph/graph/graph"
require_relative "rails_graph/graph/node"
require_relative "rails_graph/graph/relationship"

require_relative "rails_graph/graph/nodes/abstract_model"
require_relative "rails_graph/graph/nodes/column"
require_relative "rails_graph/graph/nodes/model"
require_relative "rails_graph/graph/nodes/virtual_model"

require_relative "rails_graph/graph/relationships/association"
require_relative "rails_graph/graph/relationships/attribute"
require_relative "rails_graph/graph/relationships/inheritance"

require_relative "rails_graph/helpers/associations"
require_relative "rails_graph/helpers/models"

require_relative "rails_graph/commands/build_graph"
require_relative "rails_graph/commands/export_graph"

module RailsGraph
  class Error < StandardError; end

  module_function

  def export_to_json_file(filename)
    export(graph: build, format: :json, filename: filename)
  end

  def export_to_cypher_file(filename)
    export(graph: build, format: :cypher, filename: filename)
  end

  def export_to_neo4j(host:, username:, password:)
    export(
      graph: build,
      format: :neo4j,
      host: host,
      username: username,
      password: password
    )
  end

  def build
    Commands::BuildGraph.call
  end

  def export(graph:, **opts)
    Commands::ExportGraph.call(graph: graph, **opts)
  end

  def configuration
    @configuration ||= Configuration.new
  end

  def configure
    yield configuration if block_given?
  end
end
