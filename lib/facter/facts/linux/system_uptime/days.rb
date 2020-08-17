# frozen_string_literal: true

module Facts
  module Linux
    module SystemUptime
      class Days
        FACT_NAME = 'system_uptime.days'
        ALIASES = 'uptime_days'

        def call_the_resolver
          hypervisors = Facter::Resolvers::Containers.resolve(:hypervisor)

          fact_value = if hypervisors && hypervisors[:docker]
                         Facter::Resolvers::Linux::DockerUptime.resolve(:days)
                       else
                         Facter::Resolvers::Uptime.resolve(:days)
                       end

          [Facter::ResolvedFact.new(FACT_NAME, fact_value), Facter::ResolvedFact.new(ALIASES, fact_value, :legacy)]
        end
      end
    end
  end
end
