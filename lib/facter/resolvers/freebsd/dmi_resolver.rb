# frozen_string_literal: true

module Facter
  module Resolvers
    module Freebsd
      class DmiBios < BaseResolver
        init_resolver

        class << self
          #:model

          private

          def post_resolve(fact_name)
            @fact_list.fetch(fact_name) { read_facts(fact_name) }
          end

          def read_facts(fact_name)
            require_relative 'ffi/ffi_helper'

            @fact_list[:bios_date]    = Facter::Freebsd::FfiHelper.kenv(:get, 'smbios.bios.reldate')
            @fact_list[:bios_vendor]  = Facter::Freebsd::FfiHelper.kenv(:get, 'smbios.bios.vendor')
            @fact_list[:bios_version] = Facter::Freebsd::FfiHelper.kenv(:get, 'smbios.bios.version')

            @fact_list[:product_name]   = Facter::Freebsd::FfiHelper.kenv(:get, 'smbios.system.product')
            @fact_list[:product_serial] = Facter::Freebsd::FfiHelper.kenv(:get, 'smbios.system.serial')
            @fact_list[:product_uuid]   = Facter::Freebsd::FfiHelper.kenv(:get, 'smbios.system.uuid')

            @fact_list[:sys_vendor] = Facter::Freebsd::FfiHelper.kenv(:get, 'smbios.system.maker')

            @fact_list[fact_name]
          end
        end
      end
    end
  end
end
