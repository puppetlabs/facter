# frozen_string_literal: true

module Facter
  module Resolvers
    class SELinux < BaseResolver
      @semaphore = Mutex.new
      @fact_list ||= {}

      class << self
        private

        def post_resolve(fact_name)
          @fact_list.fetch(fact_name) { retrieve_facts(fact_name) }
        end

        def retrieve_facts(fact_name)
          mountpoint = read_mounts_file if @fact_list[:enabled].nil?
          read_other_selinux_facts(mountpoint) if @fact_list[:enabled]

          @fact_list[fact_name]
        end

        def read_mounts_file
          output = Facter::Core::Execution.execute('cat /proc/self/mounts', logger: log)
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
          return unless read_selinux_config

          enforce_file = "#{mountpoint}/enforce"
          policy_file = "#{mountpoint}/policyvers"

          @fact_list[:policy_version] = Util::FileHelper.safe_read(policy_file, nil)

          enforce = Util::FileHelper.safe_read(enforce_file)
          if enforce.eql?('1')
            @fact_list[:enforced] = true
            @fact_list[:current_mode] = 'enforcing'
          else
            @fact_list[:enforced] = false
            @fact_list[:current_mode] = 'permissive'
          end
        end

        def read_selinux_config
          file_lines = Util::FileHelper.safe_readlines('/etc/selinux/config')

          file_lines.map do |line|
            @fact_list[:config_mode] = line.split('=').last.strip if line =~ /^SELINUX=/
            @fact_list[:config_policy] = line.split('=').last.strip if line =~ /^SELINUXTYPE=/
          end

          true unless file_lines.empty?
        end
      end
    end
  end
end
