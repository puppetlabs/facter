# frozen_string_literal: true

module Facts
  module Linux
    class Virtual
      FACT_NAME = 'virtual'

      def call_the_resolver
        fact_value = check_docker_lxc || check_gce
        Facter::ResolvedFact.new(FACT_NAME, fact_value)
      end

      def check_gce
        bios_vendor = Facter::Resolvers::Linux::DmiBios.resolve(:bios_vendor)
        'gce' if bios_vendor&.include?('Google')
      end

      def check_docker_lxc
        Facter::Resolvers::DockerLxc.resolve(:vm)
      end
    end
  end
end
