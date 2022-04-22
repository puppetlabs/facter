# frozen_string_literal: true

module Facts
  module Archlinux
    module Os
      class Release
        FACT_NAME = 'os.release'
        ALIASES = %w[operatingsystemmajrelease operatingsystemrelease].freeze

        def call_the_resolver
          version = Facter::Util::Facts.release_hash_from_string(version)

          return Facter::ResolvedFact.new(FACT_NAME, nil) unless version
          versions = version.split('.')
          hash = {full: version, major: versions[0], minor: versions[1]}

          [Facter::ResolvedFact.new(FACT_NAME, hash),
           Facter::ResolvedFact.new(ALIASES.first, version['major'], :legacy),
           Facter::ResolvedFact.new(ALIASES.last, version['full'], :legacy)]
        end
      end
    end
  end
end
