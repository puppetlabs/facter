# frozen_string_literal: true

module Facter
  module Resolvers
    class Containers < BaseResolver
      # :virtual
      # :hypervisor

      init_resolver

      INFO = { 'docker' => 'id', 'lxc' => 'name' }.freeze

      class << self
        private

        def post_resolve(fact_name, _options)
          @fact_list.fetch(fact_name) do
            environ_result = read_environ(fact_name)
            cgroup_result = read_cgroup(fact_name)

            if environ_result.nil? && cgroup_result.nil?
              @fact_list[:vm] = 'container_other'
              @fact_list[:hypervisor] = ''
              log.warn("Container runtime is unsupported, setting to 'container_other'")
              @fact_list[fact_name]
            else
              environ_result || cgroup_result
            end
          end
        end

        def read_cgroup(fact_name)
          output_cgroup = Facter::Util::FileHelper.safe_read('/proc/1/cgroup', nil)
          return unless output_cgroup

          output_docker = %r{docker/(.+)}.match(output_cgroup)
          output_lxc    = %r{^/lxc/([^/]+)}.match(output_cgroup)
          return if output_docker.nil? && output_lxc.nil?

          info, vm = extract_vm_and_info(output_docker, output_lxc)
          @fact_list[:vm] = vm
          @fact_list[:hypervisor] = { vm.to_sym => info } if vm
          @fact_list[fact_name]
        end

        def read_environ(fact_name)
          begin
            container = Facter::Util::Linux::Proc.getenv_for_pid(1, 'container')
          rescue StandardError => e
            log.warn("Unable to getenv for pid 1, '#{e}'")
            return nil
          end
          return if container.nil? || container.empty?

          info = {}
          case container
          when 'lxc'
            vm = 'lxc'
          when 'lxc-virtwhat'
            vm = 'lxc-virtwhat'
          when 'podman'
            vm = 'podman'
          when 'crio'
            vm = 'crio'
          when 'zone'
            return nil
          when 'systemd-nspawn'
            vm = 'systemd_nspawn'
            info = { 'id' => Facter::Util::FileHelper.safe_read('/etc/machine-id', nil).strip }
          else
            return nil
          end
          @fact_list[:vm] = vm
          @fact_list[:hypervisor] = { vm.to_sym => info } if vm
          @fact_list[fact_name]
        end

        def extract_vm_and_info(output_docker, output_lxc)
          vm = nil
          if output_docker
            vm = 'docker'
            info = output_docker[1]
          elsif output_lxc
            vm = 'lxc'
            info = output_lxc[1]
          end

          [info ? { INFO[vm] => info } : {}, vm]
        end
      end
    end
  end
end
