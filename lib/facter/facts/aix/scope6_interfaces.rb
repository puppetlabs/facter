# frozen_string_literal: true

module Facts
  module Aix
    class Scope6Interfaces
      FACT_NAME = 'scope6_.*'
      TYPE = :legacy

      def call_the_resolver
        resolved_facts = []
        interfaces = Facter::Resolvers::Aix::Networking.resolve(:interfaces)
        scope6 = Facter::Resolvers::Aix::Networking.resolve(:scope6)

        interfaces&.each do |interface_name, info|
          if info[:scope6]
            resolved_facts << Facter::ResolvedFact.new("scope6_#{interface_name}", info[:scope6], :legacy)
          end
        end

        resolved_facts << Facter::ResolvedFact.new('scope6', scope6, :legacy) if scope6
        resolved_facts
      end
    end
  end
end
