# frozen_string_literal: true

module LegacyFacter
  module Util
    module Root
      def self.root?
        require_relative '../../../facter/resolvers/windows/ffi/identity_ffi'
        IdentityFFI.privileged?
      rescue LoadError => e
        log = Facter::Log.new(self)
        log.debug("The ffi gem has not been installed: #{e}")
      end
    end
  end
end
