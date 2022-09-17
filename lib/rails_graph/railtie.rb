# frozen_string_literal: true

require "rails"

module RailsGraph
  class Railtie < ::Rails::Railtie
    railtie_name :rails_graph

    rake_tasks do
      path = File.expand_path(__dir__)
      Dir.glob("#{path}/tasks/**/*.rake").each { |f| load f }
    end
  end
end
