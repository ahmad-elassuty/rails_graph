# frozen_string_literal: true

require "securerandom"

module RailsGraph
  module Graph
    class Entity
      attr_reader :id, :name, :properties

      def initialize(name:, id: SecureRandom.uuid, properties: {})
        @id = id
        @name = name
        @properties = properties
      end

      def identifier
        id
      end
    end
  end
end
