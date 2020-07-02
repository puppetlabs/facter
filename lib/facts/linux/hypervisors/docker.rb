# frozen_string_literal: true

module Facts
  module Linux
    module Hypervisors
      class Docker
        FACT_NAME = 'hypervisors.docker'

        def call_the_resolver
          fact_value = check_docker
          Facter::ResolvedFact.new(FACT_NAME, fact_value)
        end

        def check_docker
          info = Facter::Resolvers::DockerLxc.resolve(:hypervisor)
          info[:docker] if info
        end
      end
    end
  end
end
