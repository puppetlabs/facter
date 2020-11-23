# frozen_string_literal: true

module Facter
  module Resolvers
    module Aix
      class Partitions < BaseResolver
        init_resolver

        class << self
          private

          def post_resolve(fact_name)
            @fact_list.fetch(fact_name) { query_cudv(fact_name) }
          end

          def query_cudv(fact_name)
            odmquery = Facter::Util::Aix::ODMQuery.new
            odmquery.equals('PdDvLn', 'logical_volume/lvsubclass/lvtype')

            result = odmquery.execute

            return unless result

            @fact_list[:partitions] = {}

            result.each_line do |line|
              next unless line.include?('name')

              part_name = line.split('=')[1].strip.delete('"')
              part = "/dev/#{part_name}"
              info = populate_from_lslv(part_name)
              @fact_list[:partitions][part] = info if info
            end

            @fact_list[fact_name]
          end

          def populate_from_lslv(name)
            stdout = Facter::Core::Execution.execute("lslv -L #{name}", logger: log)

            return if stdout.empty?

            info_hash =  Facter::Util::Aix::InfoExtractor.extract(stdout, /PPs:|PP SIZE|TYPE:|LABEL:|MOUNT/)
            size_bytes = compute_size(info_hash)

            part_info = {
              filesystem: info_hash['TYPE'],
              size_bytes: size_bytes,
              size: Facter::Util::Facts::UnitConverter.bytes_to_human_readable(size_bytes)
            }
            mount = info_hash['MOUNT POINT']
            label = info_hash['LABEL']
            part_info[:mount] = mount unless %r{N/A} =~ mount
            part_info[:label] = label.strip unless /None/ =~ label
            part_info
          end

          def compute_size(info_hash)
            physical_partitions = info_hash['PPs'].to_i
            size_physical_partition = info_hash['PP SIZE']
            exp = if size_physical_partition[/mega/]
                    Facter::Util::Aix::InfoExtractor::MEGABYTES_EXPONENT
                  else
                    Facter::Util::Aix::InfoExtractor::GIGABYTES_EXPONENT
                  end
            size_physical_partition.to_i * physical_partitions * exp
          end
        end
      end
    end
  end
end
