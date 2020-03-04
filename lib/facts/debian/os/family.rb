# frozen_string_literal: true

module Facts
  module Debian
    module Os
      class Family
        FACT_NAME = 'os.family'
        ALIASES = 'osfamily'

        def call_the_resolver
          fact_value = Facter::Resolvers::OsRelease.resolve(:id_like)
          fact_value ||= Facter::Resolvers::OsRelease.resolve(:id)

          [Facter::ResolvedFact.new(FACT_NAME, fact_value.capitalize),
           Facter::ResolvedFact.new(ALIASES, fact_value.capitalize, :legacy)]
        end
      end
    end
  end
end
