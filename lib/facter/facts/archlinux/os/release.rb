# frozen_string_literal: true

module Facts
  module Archlinux
    module Os
      class Release
        FACT_NAME = 'os.release'

        def call_the_resolver
          # Arch Linux is rolling release and has no version numbers
          # For historical reasons facter used the kernel version as OS version on Arch Linux
          kernelrelease = Facter::Resolvers::Uname.resolve(:kernelrelease)
          versions = kernelrelease.split('.')
          hash = { full: kernelrelease, major: versions[0], minor: versions[1] }

          Facter::ResolvedFact.new(FACT_NAME, hash)
        end
      end
    end
  end
end
