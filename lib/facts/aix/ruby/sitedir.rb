# frozen_string_literal: true

module Facts
  module Aix
    module Ruby
      class Sitedir
        FACT_NAME = 'ruby.sitedir'

        def call_the_resolver
          fact_value = Facter::Resolvers::Ruby.resolve(:sitedir)
          Facter::ResolvedFact.new(FACT_NAME, fact_value)
        end
      end
    end
  end
end
