# frozen_string_literal: true

module Facter
  module Resolvers
    class DockerLxc < BaseResolver
      # :virtual
      # :hypervisor

      @semaphore = Mutex.new
      @fact_list ||= {}
      INFO = { 'docker' => 'id', 'lxc' => 'name' }.freeze

      class << self
        private

        def post_resolve(fact_name)
          @fact_list.fetch(fact_name) { read_cgroup(fact_name) }
        end

        def read_cgroup(fact_name)
          output_cgroup = Util::FileHelper.safe_read('/proc/1/cgroup', nil)
          output_environ = Util::FileHelper.safe_read('/proc/1/environ', nil)
          return if output_cgroup.nil? || output_environ.nil?

          output_docker = %r{docker/(.+)}.match(output_cgroup)
          output_lxc = %r{^/lxc/([^/]+)}.match(output_cgroup)
          lxc_from_environ = /container=lxc/ =~ output_environ

          info, vm = extract_vm_and_info(output_docker, output_lxc, lxc_from_environ)
          @fact_list[:vm] = vm
          @fact_list[:hypervisor] = { vm.to_sym => info } if vm
          @fact_list[fact_name]
        end

        def extract_vm_and_info(output_docker, output_lxc, lxc_from_environ)
          vm = nil
          if output_docker
            vm = 'docker'
            info = output_docker[1]
          end
          vm = 'lxc' if output_lxc || lxc_from_environ
          info = output_lxc[1] if output_lxc

          [info ? { INFO[vm] => info } : {}, vm]
        end
      end
    end
  end
end
