# frozen_string_literal: true

module Facter
  module Resolvers
    module Openbsd
      class DmiBios < BaseResolver
        init_resolver

        class << self
          private

          def post_resolve(fact_name, _options)
            @fact_list.fetch(fact_name) { read_facts(fact_name) }
          end

          CTL_HW = 6
          HW_VENDOR = 14
          HW_PRODUCT = 15
          HW_VERSION = 16
          HW_SERIALNO = 17
          HW_UUID = 18

          def read_facts(fact_name)
            require 'facter/resolvers/bsd/ffi/ffi_helper'

            @fact_list[:bios_vendor]  = Facter::Bsd::FfiHelper.sysctl(:string, [CTL_HW, HW_VENDOR])
            @fact_list[:bios_version] = Facter::Bsd::FfiHelper.sysctl(:string, [CTL_HW, HW_VERSION])

            @fact_list[:product_name]   = Facter::Bsd::FfiHelper.sysctl(:string, [CTL_HW, HW_PRODUCT])
            @fact_list[:product_serial] = Facter::Bsd::FfiHelper.sysctl(:string, [CTL_HW, HW_SERIALNO])
            @fact_list[:product_uuid]   = Facter::Bsd::FfiHelper.sysctl(:string, [CTL_HW, HW_UUID])

            @fact_list[:sys_vendor] = Facter::Bsd::FfiHelper.sysctl(:string, [CTL_HW, HW_VENDOR])

            @fact_list[fact_name]
          end
        end
      end
    end
  end
end
