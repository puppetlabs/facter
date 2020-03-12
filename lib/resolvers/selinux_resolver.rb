# frozen_string_literal: true

module Facter
  module Resolvers
    class SELinux < BaseResolver
      # :name
      # :version
      # :codename

      @semaphore = Mutex.new
      @fact_list ||= {}

      class << self
        private

        def post_resolve(fact_name)
          @fact_list.fetch(fact_name) { retrieve_facts(fact_name) }
        end

        def retrieve_facts(fact_name)
          mountpoint = read_mounts_file if @fact_list[:enabled].nil?
          read_other_selinux_facts(mountpoint) if @fact_list[:enabled] && File.readable?('/etc/selinux/config')

          @fact_list[fact_name]
        end

        def read_mounts_file
          output, _s = Open3.capture2('cat /proc/self/mounts')
          @fact_list[:enabled] = false
          mountpoint = ''

          output.each_line do |line|
            next unless line =~ /selinuxfs/

            @fact_list[:enabled] = true
            mountpoint = line.split("\s")[1]
            break
          end
          mountpoint
        end

        def read_other_selinux_facts(mountpoint)
          read_selinux_config

          enforce_file = "#{mountpoint}/enforce"
          policy_file = "#{mountpoint}/policyvers"

          @fact_list[:policy_version] = File.read(policy_file) if File.readable?(policy_file)

          enforce = File.read(enforce_file) if File.readable?(enforce_file)
          if enforce.eql?('1')
            @fact_list[:enforced] = true
            @fact_list[:current_mode] = 'enforcing'
          else
            @fact_list[:enforced] = false
            @fact_list[:current_mode] = 'permissive'
          end
        end

        def read_selinux_config
          File.readlines('/etc/selinux/config').map do |line|
            @fact_list[:config_mode] = line.split('=').last.strip if line =~ /^SELINUX=/
            @fact_list[:config_policy] = line.split('=').last.strip if line =~ /^SELINUXTYPE=/
          end
        end
      end
    end
  end
end
