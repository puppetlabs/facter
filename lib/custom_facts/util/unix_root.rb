# frozen_string_literal: true

module LegacyFacter
  module Util
    module Root
      def self.root?
        Process.uid.zero?
      end
    end
  end
end
