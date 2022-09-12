# frozen_string_literal: true

require_relative "../relationship"

module RailsGraph
  module Graph
    module Relationships
      class Association < Relationship
        attr_reader :association

        def initialize(association, source, target)
          @association = association

          super(
            source: source,
            target: target,
            label: association.macro.to_s.camelize,
            name: association.name.to_s,
            properties: build_properties
          )
        end

        private

        def build_properties
          {
            polymorphic: polymorphic?,
            through: through?,
            foreign_key: foreign_key,
            foreign_type: foreign_type,
            type: type,
            dependent: dependent,
            class_name: class_name,
            optional: optional?
          }
        end

        def class_name
          name = association.polymorphic? ? association.class_name : association.klass.name

          name.delete_prefix("::")
        end

        def polymorphic?
          association.polymorphic? || false
        end

        def through?
          association.options[:through] || false
        end

        def foreign_key
          association.foreign_key.to_s
        end

        def foreign_type
          association.foreign_type.to_s
        end

        def type
          association.type
        end

        def dependent
          association.options[:dependent]
        end

        def optional?
          association.options[:optional] || false
        end
      end
    end
  end
end
