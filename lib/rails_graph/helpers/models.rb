# frozen_string_literal: true

module RailsGraph
  module Helpers
    module Models
      module_function

      def identifier(model)
        return unless model

        model.to_s.delete_prefix("::")
      end
    end
  end
end
