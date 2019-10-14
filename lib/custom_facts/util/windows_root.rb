# frozen_string_literal: true

module LegacyFacter
  module Util
    module Root
      def self.root?
        Facter::Resolvers::Identity.resolve(:privileged)
      end
    end
  end
end
