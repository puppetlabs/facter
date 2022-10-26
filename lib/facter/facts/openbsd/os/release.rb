# frozen_string_literal: true

module Facts
  module Openbsd
    module Os
      class Release
        FACT_NAME = 'os.release'
        ALIASES = %w[operatingsystemmajrelease operatingsystemrelease].freeze

        def call_the_resolver
          # From Freebsd
          # Facter::ResolvedFact.new(ALIASES.last, installed_userland, :legacy)]

          version = Facter::Resolvers::Uname.resolve(:kernelrelease)
          major, minor = version.split('.')
          [Facter::ResolvedFact.new(FACT_NAME, full: version, major: major, minor: minor),
           Facter::ResolvedFact.new(ALIASES.first, major, :legacy),
           Facter::ResolvedFact.new(ALIASES.last, version, :legacy)]
        end
      end
    end
  end
end
