# frozen_string_literal: true

module Facter
  module Resolvers
    module Freebsd
      class Virtual < BaseResolver
        init_resolver

        class << self
          #:model

          VM_GUEST_SYSCTL_NAMES = {
            'hv' => 'hyperv',
            'microsoft' => 'hyperv',
            'oracle' => 'virtualbox',
            'xen' => 'xenu',
            'none' => nil
          }.freeze

          private

          def post_resolve(fact_name)
            @fact_list.fetch(fact_name) { read_facts(fact_name) }
          end

          def read_facts(fact_name)
            require_relative 'ffi/ffi_helper'

            if Facter::Freebsd::FfiHelper.sysctl_by_name(:long, 'security.jail.jailed').zero?
              vm = Facter::Freebsd::FfiHelper.sysctl_by_name(:string, 'kern.vm_guest')

              vm = VM_GUEST_SYSCTL_NAMES[vm] if VM_GUEST_SYSCTL_NAMES.key?(vm)

              @fact_list[:vm] = vm
            else
              @fact_list[:vm] = 'jail'
            end

            @fact_list[fact_name]
          end
        end
      end
    end
  end
end
