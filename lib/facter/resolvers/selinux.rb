# frozen_string_literal: true

module Facter
  module Resolvers
    class SELinux < BaseResolver
      init_resolver

      class << self
        private

        def post_resolve(fact_name, _options)
          @fact_list.fetch(fact_name) { retrieve_facts(fact_name) }
        end

        def retrieve_facts(fact_name)
          mountpoint = selinux_mountpoint

          @fact_list[:enabled] = !mountpoint.empty? && read_selinux_config
          read_other_selinux_facts(mountpoint) if @fact_list[:enabled]

          @fact_list[fact_name]
        end

        def selinux_mountpoint
          output = Facter::Core::Execution.execute('cat /proc/self/mounts', logger: log)
          mountpoint = ''

          output.each_line do |line|
            next unless /selinuxfs/.match?(line)

            mountpoint = line.split("\s")[1]
            break
          end
          mountpoint
        end

        def read_other_selinux_facts(mountpoint)
          enforce_file = "#{mountpoint}/enforce"
          policy_file = "#{mountpoint}/policyvers"

          @fact_list[:policy_version] = Facter::Util::FileHelper.safe_read(policy_file, nil)

          enforce = Facter::Util::FileHelper.safe_read(enforce_file)
          if enforce.eql?('1')
            @fact_list[:enforced] = true
            @fact_list[:current_mode] = 'enforcing'
          else
            @fact_list[:enforced] = false
            @fact_list[:current_mode] = 'permissive'
          end
        end

        def read_selinux_config
          file_lines = Facter::Util::FileHelper.safe_readlines('/etc/selinux/config')

          file_lines.map do |line|
            @fact_list[:config_mode] = line.split('=').last.strip if /^SELINUX=/.match?(line)
            @fact_list[:config_policy] = line.split('=').last.strip if /^SELINUXTYPE=/.match?(line)
          end

          !file_lines.empty? ? true : false
        end
      end
    end
  end
end
