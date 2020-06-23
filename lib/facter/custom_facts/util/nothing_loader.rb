# frozen_string_literal: true

module LegacyFacter
  module Util
    # An external fact loader that doesn't load anything
    # This makes it possible to disable loading
    # of external facts
    class NothingLoader
      def load(collection); end
    end
  end
end
