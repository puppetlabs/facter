# frozen_string_literal: true

module Facts
  module Solaris
    class Ldom
      FACT_NAME = 'ldom'
      ALIASES = %w[
        ldom_domainchassis
        ldom_domaincontrol
        ldom_domainname
        ldom_domainrole_control
        ldom_domainrole_impl
        ldom_domainrole_io
        ldom_domainrole_root
        ldom_domainrole_service
        ldom_domainuuid
      ].freeze

      def initialize
        @log = Facter::Log.new(self)
      end

      def call_the_resolver
        @log.debug('Solving the ldom fact.')
        fact_value = resolve_fact
        return Facter::ResolvedFact.new(FACT_NAME, nil) if fact_value.nil?

        create_resolved_facts_list(fact_value)
      end

      def resolve_fact
        chassis_serial = resolve(:chassis_serial)
        return nil if !chassis_serial || chassis_serial.empty?

        {
          domainchassis: chassis_serial,
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
      end

      def resolve(key)
        Facter::Resolvers::Solaris::Ldom.resolve(key)
      end

      def create_resolved_facts_list(fact_value)
        resolved_facts = [Facter::ResolvedFact.new(FACT_NAME, fact_value)]
        ALIASES.each do |fact_alias|
          key = fact_alias.split('_')[1..-1].map!(&:to_sym)
          resolved_facts << Facter::ResolvedFact.new(fact_alias, fact_value.dig(*key), :legacy)
        end

        resolved_facts
      end
    end
  end
end
