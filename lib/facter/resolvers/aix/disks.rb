# frozen_string_literal: true

module Facter
  module Resolvers
    module Aix
      class Disks < BaseResolver
        @semaphore = Mutex.new
        @fact_list ||= {}
        class << self
          private

          def post_resolve(fact_name)
            @fact_list.fetch(fact_name) { execute_lspv(fact_name) }
          end

          def execute_lspv(fact_name)
            @fact_list[:disks] = {}

            result = Facter::Core::Execution.execute('lspv', logger: log)

            return if result.empty?

            result.each_line do |line|
              disk_name = line.split(' ')[0].strip
              size = find_size(disk_name)
              @fact_list[:disks][disk_name] = size if size
            end

            @fact_list[fact_name]
          end

          def find_size(name)
            stdout = Facter::Core::Execution.execute("lspv #{name}", logger: log)

            return if stdout.empty?

            info_size = InfoExtractor.extract(stdout, /PP SIZE:|TOTAL PPs:|FREE PPs:|PV STATE:/)

            return unless info_size['PV STATE']

            size_bytes = compute_size(info_size)

            {
              size_bytes: size_bytes,
              size: Facter::FactsUtils::UnitConverter.bytes_to_human_readable(size_bytes)
            }
          end

          def compute_size(size_hash)
            physical_partitions = size_hash['TOTAL PPs'].to_i + size_hash['FREE PPs'].to_i
            size_physical_partition = size_hash['PP SIZE']
            exp = if size_physical_partition[/mega/]
                    InfoExtractor::MEGABYTES_EXPONENT
                  else
                    InfoExtractor::GIGABYTES_EXPONENT
                  end
            size_physical_partition.to_i * physical_partitions * exp
          end
        end
      end
    end
  end
end
