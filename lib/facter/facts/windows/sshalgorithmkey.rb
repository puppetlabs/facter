# frozen_string_literal: true

module Facts
  module Windows
    class Sshalgorithmkey
      FACT_NAME = 'ssh.*key'
      TYPE = :legacy

      def call_the_resolver
        facts = []
        privileged = Facter::Resolvers::Identity.resolve(:privileged)

        return facts unless privileged

        result = Facter::Resolvers::Windows::Ssh.resolve(:ssh)

        result&.each { |ssh| facts << Facter::ResolvedFact.new("ssh#{ssh.name.to_sym}key", ssh.key, :legacy) }
        facts
      end
    end
  end
end
