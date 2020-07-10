# frozen_string_literal: true

# A composite loader that allows for more than one
# default directory loader

module LegacyFacter
  module Util
    class CompositeLoader
      def initialize(loaders)
        @loaders = loaders
      end

      def load(collection)
        @loaders.each { |loader| loader.load(collection) }
      end
    end
  end
end
