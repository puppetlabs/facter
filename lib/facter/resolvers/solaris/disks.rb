# frozen_string_literal: true

module Facter
  module Resolvers
    module Solaris
      class Disks < BaseResolver
        init_resolver

        class << self
          private

          def post_resolve(fact_name)
            @fact_list.fetch(fact_name) { read_disks_info(fact_name) }
          end

          def read_disks_info(fact_name)
            return unless File.executable?('/usr/bin/kstat')

            log.debug('loading disks info')

            kstat_output = Facter::Core::Execution.execute('/usr/bin/kstat sderr', logger: log)
            return if kstat_output.empty?

            @fact_list[fact_name] = parse(kstat_output)
          end

          def parse(kstat_output)
            disks = {}

            names = kstat_output.scan(/name:\s+(\w+)/).flatten
            products = kstat_output.scan(/Product\s+(.+)/).flatten
            vendors = kstat_output.scan(/Vendor\s+(\w+)/).flatten
            sizes = kstat_output.scan(/Size\s+(\w+)/).flatten

            names.each_with_index do |name, index|
              disk_size = sizes[index].to_i
              disks[name] = {
                product: products[index],
                size: Facter::Util::Facts::UnitConverter.bytes_to_human_readable(disk_size),
                size_bytes: disk_size,
                vendor: vendors[index]
              }
            end
            disks
          end
        end
      end
    end
  end
end
