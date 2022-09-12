# frozen_string_literal: true

require_relative "base"
require "json"

module RailsGraph
  module Exporters
    class Json < Base
      def self.export(graph:, filename:)
        json = graph.to_json

        File.write(filename, json, mode: "w")
      end
    end
  end
end
