# frozen_string_literal: true

require 'win32/registry'

module Facter
  module Resolvers
    module Windows
      class Fips < BaseResolver
        # :fips_enabled
        @semaphore = Mutex.new
        @fact_list ||= {}
        class << self
          def resolve(fact_name)
            @semaphore.synchronize do
              result ||= @fact_list[fact_name]
              subscribe_to_manager
              result || read_fact_from_registry(fact_name)
            end
          end

          private

          def read_fact_from_registry(fact_name)
            reg = ::Win32::Registry::HKEY_LOCAL_MACHINE
                  .open('System\\CurrentControlSet\\Control\\Lsa\\FipsAlgorithmPolicy')
            reg.each { |name, _value| @fact_list[:fips_enabled] = reg[name] != 0 if name == 'Enabled' }
            reg.close

            @fact_list[:fips_enabled] ||= false
            @fact_list[fact_name]
          end
        end
      end
    end
  end
end
