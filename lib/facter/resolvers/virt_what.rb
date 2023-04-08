# frozen_string_literal: true

module Facter
  module Resolvers
    class VirtWhat < BaseResolver
      init_resolver

      class << self
        private

        def post_resolve(fact_name, _options)
          @fact_list.fetch(fact_name) { retrieve_from_virt_what(fact_name) }
        end

        def retrieve_from_virt_what(fact_name)
          output = Facter::Core::Execution.execute('virt-what', logger: log)

          @fact_list[:vm] = determine_xen(output)
          @fact_list[:vm] ||= determine_other(output)
          retrieve_vserver unless @fact_list[:vserver]

          @fact_list[fact_name]
        end

        def determine_xen(output)
          xen_info = /^xen\n.*/.match(output)

          return unless xen_info

          xen_info = xen_info.to_s
          return 'xenu' if /xen-domu/.match?(xen_info)
          return 'xenhvm' if /xen-hvm/.match?(xen_info)
          return 'xen0' if /xen-dom0/.match?(xen_info)
        end

        def determine_other(output)
          values = output.split("\n")
          other_vm = values.first
          return unless other_vm

          return 'zlinux' if /ibm_systemz/.match?(other_vm)
          return retrieve_vserver if /linux_vserver/.match?(other_vm)
          return (values - ['redhat']).first if values.include?('redhat')

          other_vm
        end

        def retrieve_vserver
          proc_status_content = Facter::Util::FileHelper.safe_readlines('/proc/self/status', nil)
          return unless proc_status_content

          proc_status_content.each do |line|
            parts = line.split("\s")
            next unless parts.size.equal?(2)

            next unless /^s_context:|^VxID:/.match?(parts[0])
            return @fact_list[:vserver] = 'vserver_host' if parts[1] == '0'

            return @fact_list[:vserver] = 'vserver'
          end
        end
      end
    end
  end
end
