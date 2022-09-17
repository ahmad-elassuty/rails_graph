# frozen_string_literal: true

require "optparse"

module RailsGraph
  module Helpers
    module OptionsParser
      def parse_options(banner, arguments)
        parser = OptionParser.new
        parser.banner = banner
        options = {}

        arguments.each { |argument| parser.on(*argument) }

        parser.parse!(parser.order!(ARGV), into: options)

        options
      end
    end
  end
end
