# frozen_string_literal: true

module Facts
  module Linux
    module Os
      class Family
        FACT_NAME = 'os.family'
        ALIASES = 'osfamily'

        def call_the_resolver
          id = Facter::Resolvers::OsRelease.resolve(:id_like)
          id ||= Facter::Resolvers::OsRelease.resolve(:id)

          fact_value = Facter::Util::Facts.discover_family(id)

          [Facter::ResolvedFact.new(FACT_NAME, fact_value.capitalize),
           Facter::ResolvedFact.new(ALIASES, fact_value.capitalize, :legacy)]
        end
      end
    end
  end
end
