# frozen_string_literal: true

module Facts
  module Linux
    class Hypervisors
      FACT_NAME = 'hypervisors'

      def call_the_resolver
        fact_value = check_docker_lxc
        Facter::ResolvedFact.new(FACT_NAME, fact_value)
      end

      def check_docker_lxc
        Facter::Resolvers::DockerLxc.resolve(:hypervisor)
      end
    end
  end
end
