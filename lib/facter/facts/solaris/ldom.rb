# frozen_string_literal: true

module Facts
  module Solaris
    class Ldom
      FACT_NAME = 'ldom'

      def initialize
        @log = Facter::Log.new(self)
      end

      def call_the_resolver
        fact_value = {
          domainchassis: resolve(:chassis_serial),
          domaincontrol: resolve(:control_domain),
          domainname: resolve(:domain_name),
          domainrole: {
            control: resolve(:role_control),
            impl: resolve(:role_impl),
            io: resolve(:role_io),
            root: resolve(:role_root),
            service: resolve(:role_service)
          },
          domainuuid: resolve(:domain_uuid)
        }

        Facter::ResolvedFact.new(FACT_NAME, fact_value)
      end

      def resolve(key)
        Facter::Resolvers::Solaris::Ldom.resolve(key)
      end
    end
  end
end
