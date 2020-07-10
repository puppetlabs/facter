# frozen_string_literal: true

module Facts
  module Solaris
    module Ruby
      class Version
        FACT_NAME = 'ruby.version'
        ALIASES = 'rubyversion'

        def call_the_resolver
          fact_value = Facter::Resolvers::Ruby.resolve(:version)
          [Facter::ResolvedFact.new(FACT_NAME, fact_value), Facter::ResolvedFact.new(ALIASES, fact_value, :legacy)]
        end
      end
    end
  end
end
