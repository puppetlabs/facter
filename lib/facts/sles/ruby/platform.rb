# frozen_string_literal: true

module Facts
  module Sles
    module Ruby
      class Platform
        FACT_NAME = 'ruby.platform'

        def call_the_resolver
          fact_value = Facter::Resolvers::Ruby.resolve(:platform)
          Facter::ResolvedFact.new(FACT_NAME, fact_value)
        end
      end
    end
  end
end
