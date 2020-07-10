# frozen_string_literal: true

module Facter
  module Resolvers
    class DmiDecode < BaseResolver
      @semaphore = Mutex.new
      @fact_list ||= {}

      ADDRESS_TO_VERSION = {
        0xe8480 => 'ESXi 2.5',
        0xe7c70 => 'ESXi 3.0',
        0xe66c0 => 'ESXi 3.5',
        0xe7910 => 'ESXi 3.5',
        0xea550 => 'ESXi 4.0',
        0xea6c0 => 'ESXi 4.0',
        0xea2e0 => 'ESXi 4.1',
        0xe72c0 => 'ESXi 5.0',
        0xea0c0 => 'ESXi 5.1',
        0xea050 => 'ESXi 5.5',
        0xe99e0 => 'ESXi 6.0',
        0xE9A40 => 'ESXi 6.0',
        0xea580 => 'ESXi 6.5',
        0xEA520 => 'ESXi 6.7',
        0xEA490 => 'ESXi 6.7',
        0xea5e0 => 'Fusion 8.5'
      }.freeze

      class << self
        private

        def post_resolve(fact_name)
          @fact_list.fetch(fact_name) { run_dmidecode(fact_name) }
        end

        def run_dmidecode(fact_name)
          output = Facter::Core::Execution.execute('dmidecode', logger: log)

          @fact_list[:virtualbox_version] = output.match(/vboxVer_(\S+)/)&.captures&.first
          @fact_list[:virtualbox_revision] = output.match(/vboxRev_(\S+)/)&.captures&.first
          @fact_list[:vmware_version] = extract_vmware_version(output)

          @fact_list[fact_name]
        end

        def extract_vmware_version(output)
          address_of_version = output.match(/Address:\s(0x[a-zA-Z0-9]*)/)&.captures&.first

          ADDRESS_TO_VERSION[address_of_version&.hex]
        end
      end
    end
  end
end
