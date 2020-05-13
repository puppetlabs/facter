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
        primary = Facter::Resolvers::NetworkingLinux.resolve(:primary_interface)
        interfaces&.each do |interface_name, info|
          scope6_interfaces["scope6_#{interface_name}"] = info[:scope6] if info[:scope6]
        end

        scope6_interfaces.each { |fact, value| resolved_facts << Facter::ResolvedFact.new(fact, value, :legacy) }
        if interfaces && primary
          resolved_facts << Facter::ResolvedFact.new('scope6', interfaces[primary][:scope6], :legacy)
        end
        resolved_facts
      end
    end
  end
end
