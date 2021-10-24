# frozen_string_literal: true

module LegacyFacter
  module Util
    module Root
      def self.root?
        require 'facter/resolvers/windows/ffi/identity_ffi'
        IdentityFFI.privileged?
      end
    end
  end
end
