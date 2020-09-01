# frozen_string_literal: true

module Facts
  module Freebsd
    module Ruby
      class Platform
        FACT_NAME = 'ruby.platform'
        ALIASES = 'rubyplatform'

        def call_the_resolver
          fact_value = Facter::Resolvers::Ruby.resolve(:platform)

          [Facter::ResolvedFact.new(FACT_NAME, fact_value), Facter::ResolvedFact.new(ALIASES, fact_value, :legacy)]
        end
      end
    end
  end
end
