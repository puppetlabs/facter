# frozen_string_literal: true

module Facts
  module Macosx
    module SystemProfiler
      class Username
        FACT_NAME = 'system_profiler.username'
        ALIASES = 'sp_user_name'

        def call_the_resolver
          fact_value = Facter::Resolvers::SystemProfiler.resolve(:user_name)
          [Facter::ResolvedFact.new(FACT_NAME, fact_value), Facter::ResolvedFact.new(ALIASES, fact_value, :legacy)]
        end
      end
    end
  end
end
