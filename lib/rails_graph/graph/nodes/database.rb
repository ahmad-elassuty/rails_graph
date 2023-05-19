# frozen_string_literal: true

require_relative "../node"

module RailsGraph
  module Graph
    module Nodes
      class Database < Node
        attr_reader :configs

        def initialize(configs)
          @configs = configs

          super(labels: "Database", name: configs.name, properties: build_properties)
        end

        def identifier
          "database_#{name}"
        end
        
        private

        def build_properties
          {
            pool_size: configs.pool,
            adapter: configs.adapter,
            schema_cache_path: configs.schema_cache_path,
            replica: configs.replica? || false,
            database_name: configs.database,
            reaping_frequency: configs.reaping_frequency,
            min_threads: configs.min_threads,
            max_threads: configs.max_threads
          }
        end
      end
    end
  end
end
