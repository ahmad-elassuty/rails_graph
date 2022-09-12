# frozen_string_literal: true

require_relative "entity"

module RailsGraph
  module Graph
    class Relationship < Entity
      attr_reader :source, :target, :label

      def initialize(source:, target:, label:, **opts)
        @source = source
        @target = target
        @label  = label

        super(**opts)
      end

      def identifier
        "#{label}##{source.identifier}##{target.identifier}##{name}"
      end

      def as_json(_options = nil)
        {
          id: id,
          label: label,
          name: name,
          source: source.id,
          target: target.id,
          properties: properties
        }
      end
    end
  end
end
