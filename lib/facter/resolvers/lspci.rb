# frozen_string_literal: true

module Facter
  module Resolvers
    class Lspci < BaseResolver
      init_resolver

      REGEX_VALUES = { 'VirtualBox' => 'virtualbox', 'XenSource' => 'xenhvm',
                       'Microsoft Corporation Hyper-V' => 'hyperv', 'Class 8007: Google, Inc' => 'gce',
                       'VM[wW]are' => 'vmware', '1ab8:' => 'parallels', '[Pp]arallels' => 'parallels',
                       '(?i)(virtio)' => 'kvm' }.freeze

      class << self
        private

        def post_resolve(fact_name, _options)
          @fact_list.fetch(fact_name) { lspci_command(fact_name) }
        end

        def lspci_command(fact_name)
          output = Facter::Core::Execution.execute('lspci', logger: log)
          return if output.empty?

          @fact_list[:vm] = retrieve_vm(output)
          @fact_list[fact_name]
        end

        def retrieve_vm(output)
          output.each_line { |line| REGEX_VALUES.each { |key, value| return value if /#{key}/.match?(line) } }

          nil
        end
      end
    end
  end
end
