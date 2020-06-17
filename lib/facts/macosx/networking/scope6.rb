# frozen_string_literal: true

module Facts
  module Macosx
    module Networking
      class Scope6
        FACT_NAME = 'networking.scope6'

        def call_the_resolver
          interfaces = Facter::Resolvers::Macosx::Networking.resolve(:interfaces)
          primary = Facter::Resolvers::Macosx::Networking.resolve(:primary_interface)

          fact_value = interfaces.dig(primary, :scope6) unless interfaces.nil?

          Facter::ResolvedFact.new(FACT_NAME, fact_value)
        end
      end
    end
  end
end
