# frozen_string_literal: true

module Facter
  module Resolvers
    class VirtWhat < BaseResolver
      @fact_list ||= {}

      class << self
        private

        def post_resolve(fact_name)
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
          return 'xenu' if xen_info =~ /xen-domu/
          return 'xenhvm' if xen_info =~ /xen-hvm/
          return 'xen0' if xen_info =~ /xen-dom0/
        end

        def determine_other(output)
          other_vm = output.split("\n").first
          return unless other_vm

          return 'zlinux' if other_vm =~ /ibm_systemz/
          return retrieve_vserver if other_vm =~ /linux_vserver/

          other_vm
        end

        def retrieve_vserver
          proc_status_content = Facter::Util::FileHelper.safe_readlines('/proc/self/status', nil)
          return unless proc_status_content

          proc_status_content.each do |line|
            parts = line.split("\s")
            next unless parts.size.equal?(2)

            next unless parts[0] =~ /^s_context:|^VxID:/
            return @fact_list[:vserver] = 'vserver_host' if parts[1] == '0'

            return @fact_list[:vserver] = 'vserver'
          end
        end
      end
    end
  end
end
