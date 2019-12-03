# frozen_string_literal: true

require 'win32/registry'

module Facter
  module Resolvers
    class NetKVM < BaseResolver
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
          reg = ::Win32::Registry::HKEY_LOCAL_MACHINE.open('SYSTEM\\CurrentControlSet\\Services')
          build_fact_list(reg)
          reg.close

          @fact_list[fact_name]
        end

        def build_fact_list(reg)
          @fact_list[:kvm] = reg.keys.include?('netkvm')
        end
      end
    end
  end
end
