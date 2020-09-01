# frozen_string_literal: true

module Facts
  module Solaris
    module Ruby
      class Sitedir
        FACT_NAME = 'ruby.sitedir'
        ALIASES = 'rubysitedir'

        def call_the_resolver
          fact_value = Facter::Resolvers::Ruby.resolve(:sitedir)
          [Facter::ResolvedFact.new(FACT_NAME, fact_value), Facter::ResolvedFact.new(ALIASES, fact_value, :legacy)]
        end
      end
    end
  end
end
