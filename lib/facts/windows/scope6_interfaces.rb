# frozen_string_literal: true

module Facter
  module Windows
    class Scope6Interfaces
      FACT_NAME = 'scope6_.*'

      def call_the_resolver
        arr = []
        result = {}
        interfaces = Resolvers::Networking.resolve(:interfaces)
        interfaces.each { |interface_name, info| result["scope6_#{interface_name}"] = info[:scope6] if info[:scope6] }

        result.each { |fact, value| arr << ResolvedFact.new(fact, value, :legacy) }
        arr
      end
    end
  end
end
