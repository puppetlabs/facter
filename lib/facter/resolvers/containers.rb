# frozen_string_literal: true

module Facter
  module Resolvers
    class Containers < BaseResolver
      # :vm
      # :hypervisor

      init_resolver

      class << self
        private

        def post_resolve(fact_name, _options)
          @fact_list.fetch(fact_name) do
            vm, hypervisor = read_cgroup || read_environ

            @fact_list[:vm] = vm
            @fact_list[:hypervisor] = hypervisor
            @fact_list[fact_name]
          end
        end

        # Read /proc/1/cgroup to determine if we're running in docker or lxc
        # returning the vm and hypervisor info. If none found, return nil.
        #
        # @return Array[<String, Hash>], nil
        def read_cgroup
          output_cgroup = Facter::Util::FileHelper.safe_read('/proc/1/cgroup', nil)
          return unless output_cgroup

          # '+' matches one or more characters, so if there's a match, the
          # capture group must be non-empty
          output_docker = %r{docker/(?<id>.+)}.match(output_cgroup)
          output_lxc = %r{^/lxc/(?<name>[^/]+)}.match(output_cgroup)

          if File.exist?('/.dockerenv')
            vm = 'docker'
            info = output_docker && output_docker[:id] ? { 'id' => output_docker[:id] } : {}
          elsif output_docker
            vm = 'docker'
            info = { 'id' => output_docker[:id] }
          elsif output_lxc
            vm = 'lxc'
            info = { 'name' => output_lxc[:name] }
          else
            # fallback to read_environ
            return nil
          end

          [vm, { vm.to_sym => info }]
        end

        # Read the `container` environment variable from /proc/1/environ to
        # determine the vm and hypervisor info. If none found, return nil.
        #
        # @return Array[<String, Hash>], nil
        def read_environ
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
            machine_id = Facter::Util::FileHelper.safe_read('/etc/machine-id', nil)
            info = if machine_id
                     { 'id' => machine_id.strip }
                   else
                     {}
                   end
          else
            log.debug("Container runtime '#{container}' is not recognized, ignoring")
            return nil
          end

          [vm, { vm.to_sym => info }]
        end
      end
    end
  end
end
