# frozen_string_literal: true

module Facts
  module Macosx
    module Os
      class Release
        FACT_NAME = 'os.release'
        ALIASES = %w[operatingsystemmajrelease operatingsystemrelease].freeze

        def call_the_resolver
          fact_value = Facter::Resolvers::Uname.resolve(:kernelrelease)
          versions = fact_value.split('.')
          release = {
            'full' => fact_value,
            'major' => versions[0],
            'minor' => versions[1]
          }

          [Facter::ResolvedFact.new(FACT_NAME, release),
           Facter::ResolvedFact.new(ALIASES.first, versions[0], :legacy),
           Facter::ResolvedFact.new(ALIASES.last, fact_value, :legacy)]
        end
      end
    end
  end
end
