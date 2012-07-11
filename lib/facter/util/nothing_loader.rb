# An external fact loader that doesn't load anything

# This makes it possible to disable loading
# of external facts

module Facter
  module Util

    class NothingLoader

      def load(collection)
      end
    end
  end
end
