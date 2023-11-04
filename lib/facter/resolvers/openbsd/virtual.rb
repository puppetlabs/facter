# frozen_string_literal: true

module Facter
  module Resolvers
    module Openbsd
      class Virtual < BaseResolver
        init_resolver

        class << self
          #:model

          VM_GUEST_SYSCTL_NAMES = {
            'VMM' => 'vmm',
            'vServer' => 'vserver',
            'oracle' => 'virtualbox',
            'xen' => 'xenu',
            'none' => nil
          }.freeze

          private

          def post_resolve(fact_name, _options)
            @fact_list.fetch(fact_name) { read_facts(fact_name) }
          end

          CTL_HW = 6
          HW_PRODUCT = 15

          def read_facts(fact_name)
            require 'facter/resolvers/bsd/ffi/ffi_helper'

            vm = Facter::Bsd::FfiHelper.sysctl(:string, [CTL_HW, HW_PRODUCT])
            vm = VM_GUEST_SYSCTL_NAMES[vm] if VM_GUEST_SYSCTL_NAMES.key?(vm)
            @fact_list[:vm] = vm
            @fact_list[fact_name]
          end
        end
      end
    end
  end
end
