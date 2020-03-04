# frozen_string_literal: true

module Facts
  module El
    module Os
      class Name
        FACT_NAME = 'os.name'
        ALIASES = 'operatingsystem'

        def call_the_resolver
          fact_value = Facter::Resolvers::OsRelease.resolve(:name)
          fact_value ||= Facter::Resolvers::RedHatRelease.resolve(:name)

          [Facter::ResolvedFact.new(FACT_NAME, fact_value), Facter::ResolvedFact.new(ALIASES, fact_value, :legacy)]
        end
      end
    end
  end
end
