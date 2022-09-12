# frozen_string_literal: true

module RailsGraph
  module Helpers
    module Models
      module_function

      def identifier(model)
        model.to_s.delete_prefix("::")
      end
    end
  end
end
