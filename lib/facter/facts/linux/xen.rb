# frozen_string_literal: true

module Facts
  module Linux
    class Xen
      FACT_NAME = 'xen'
      ALIASES = 'xendomains'

      def call_the_resolver
        xen_type = check_virt_what || check_xen
        return Facter::ResolvedFact.new(FACT_NAME, nil) if !xen_type || xen_type != 'xen0'

        domains = Facter::Resolvers::Xen.resolve(:domains) || []

        [Facter::ResolvedFact.new(FACT_NAME, { domains: domains }),
         Facter::ResolvedFact.new(ALIASES, domains.entries.join(','), :legacy)]
      end

      def check_virt_what
        Facter::Resolvers::VirtWhat.resolve(:vm)
      end

      def check_xen
        Facter::Resolvers::Xen.resolve(:vm)
      end
    end
  end
end
