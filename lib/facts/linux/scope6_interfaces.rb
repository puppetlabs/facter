# frozen_string_literal: true

module Facts
  module Linux
    class Scope6Interfaces
      FACT_NAME = 'scope6_.*'
      TYPE = :legacy

      def call_the_resolver
        resolved_facts = []
        scope6_interfaces = {}
        interfaces = Facter::Resolvers::NetworkingLinux.resolve(:interfaces)
        primary_scope6 = Facter::Resolvers::NetworkingLinux.resolve(:scope6)

        interfaces&.each do |interface_name, info|
          scope6_interfaces["scope6_#{interface_name}"] = info[:scope6] if info[:scope6]
        end

        scope6_interfaces.each { |fact, value| resolved_facts << Facter::ResolvedFact.new(fact, value, :legacy) }
        resolved_facts << Facter::ResolvedFact.new('scope6', primary_scope6, :legacy) if primary_scope6
        resolved_facts
      end
    end
  end
end
