# frozen_string_literal: true

module Facts
  module Linux
    class Virtual
      FACT_NAME = 'virtual'

      def call_the_resolver
        fact_value = Facter::Resolvers::DockerLxc.resolve(:vm)
        Facter::ResolvedFact.new(FACT_NAME, fact_value)
      end
    end
  end
end
