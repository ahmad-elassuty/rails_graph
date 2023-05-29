# frozen_string_literal: true

require "rails_graph/version"
require "rails_graph/error"
require "rails_graph/configuration"
require "rails_graph/railtie"

require "rails_graph/commands/build_graph"
require "rails_graph/commands/export_graph"
require "rails_graph/inspector"

module RailsGraph
  module_function

  def load_entities
    Rails.application.eager_load!
  end

  def build_graph(configuration: nil)
    Commands::BuildGraph.call(configuration: configuration || RailsGraph.configuration)
  end

  def export_graph(graph:, **opts)
    Commands::ExportGraph.call(graph: graph, **opts)
  end

  def configuration
    @configuration ||= Configuration.new
  end

  def configure
    yield configuration if block_given?
  end
end
