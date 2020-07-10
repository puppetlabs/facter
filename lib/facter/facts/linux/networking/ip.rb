# frozen_string_literal: true

module Facts
  module Linux
    module Networking
      class Ip
        FACT_NAME = 'networking.ip'
        ALIASES = 'ipaddress'

        def call_the_resolver
          fact_value = Facter::Resolvers::NetworkingLinux.resolve(:ip)

          [Facter::ResolvedFact.new(FACT_NAME, fact_value), Facter::ResolvedFact.new(ALIASES, fact_value, :legacy)]
        end
      end
    end
  end
end
