# frozen_string_literal: true

require "#{ROOT_DIR}/ext/cpuid.so"

module Facter
  module Resolvers
    class CpuidSource < BaseResolver
      @semaphore = Mutex.new
      @fact_list ||= {}
      VENDOR_LEAF = 0x40000000

      # :vendor
      # :xen

      class << self
        def resolve(fact_name)
          @semaphore.synchronize do
            result ||= @fact_list[fact_name]
            subscribe_to_manager
            result || find_hypervisor(fact_name)
          end
        end

        private

        def find_hypervisor(fact_name)
          result = Cpuid.find(VENDOR_LEAF)
          if fact_name == :vendor
            @fact_list[:vendor] = result[1]
          else
            @fact_list[:xen] = check_for_xen(result)
          end
          @fact_list[fact_name]
        end

        def check_for_xen(result)
          xen_vendor = 'XenVMMXenVMM'
          max_entries = result[0]

          return result[1].eql?(xen_vendor) if max_entries < 0x4 || max_entries >= 0x10000

          leaf = VENDOR_LEAF + 0x100

          while leaf <= VENDOR_LEAF + max_entries
            return true if Cpuid.find(leaf)[1].eql?(xen_vendor)

            leaf += 0x100
          end
          false
        end
      end
    end
  end
end
