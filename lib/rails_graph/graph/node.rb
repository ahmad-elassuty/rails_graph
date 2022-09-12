# frozen_string_literal: true

require_relative "entity"

module RailsGraph
  module Graph
    class Node < Entity
      attr_reader :labels

      def initialize(labels: [], **opts)
        @labels = Array(labels)

        super(**opts)
      end

      def as_json(_options = nil)
        {
          id: id,
          labels: labels,
          name: name,
          properties: properties
        }
      end
    end
  end
end
