# frozen_string_literal: true

module Facts
  module Linux
    class PuppetVersion
      FACT_NAME = 'puppetversion'

      def call_the_resolver
        fact_value = Facter::Resolvers::PuppetVersionResolver.resolve(:puppetversion)

        Facter::ResolvedFact.new(FACT_NAME, fact_value)
      end
    end
  end
end
