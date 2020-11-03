# frozen_string_literal: true

require 'win32/registry'

module Facter
  module Resolvers
    module Windows
      class Fips < BaseResolver
        # :fips_enabled
        init_resolver

        class << self
          private

          def post_resolve(fact_name)
            @fact_list.fetch(fact_name) { read_fact_from_registry(fact_name) }
          end

          def read_fact_from_registry(fact_name)
            reg = ::Win32::Registry::HKEY_LOCAL_MACHINE
                  .open('System\\CurrentControlSet\\Control\\Lsa\\FipsAlgorithmPolicy')
            @fact_list[:fips_enabled] = reg['Enabled'] != 0 if reg.any? { |name, _value| name == 'Enabled' }
            reg.close

            @fact_list[:fips_enabled] ||= false
            @fact_list[fact_name]
          end
        end
      end
    end
  end
end
