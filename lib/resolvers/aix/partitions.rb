# frozen_string_literal: true

module Facter
  module Resolvers
    module Aix
      class Partitions < BaseResolver
        @log = Facter::Log.new(self)
        @semaphore = Mutex.new
        @fact_list ||= {}
        class << self
          private

          MEGABYTES_EXPONENT = 1024**2
          GIGABYTES_EXPONENT = 1024**3

          def post_resolve(fact_name)
            @fact_list.fetch(fact_name) { query_cudv(fact_name) }
          end

          def query_cudv(fact_name)
            @fact_list[:partitions] = {}

            odmquery = Facter::ODMQuery.new
            odmquery.equals('PdDvLn', 'logical_volume/lvsubclass/lvtype')

            result = odmquery.execute

            return unless result

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
            stdout, stderr, _status = Open3.capture3("lslv -L #{name}")
            if stdout.empty?
              @log.debug(stderr)
              return
            end

            info_hash = extract_info(stdout)
            size_bytes = compute_size(info_hash)

            part_info = {
              filesystem: info_hash['TYPE'],
              size_bytes: size_bytes,
              size: Facter::FactsUtils::UnitConverter.bytes_to_human_readable(size_bytes)
            }
            mount = info_hash['MOUNTPOINT']
            label = info_hash['LABEL']
            part_info[:mount] = mount unless %r{N/A} =~ mount
            part_info[:label] = label unless /None/ =~ label
            part_info
          end

          def extract_info(lsl_content)
            lsl_content = lsl_content.strip.split("\n").map do |line|
              next unless /PPs:|PP SIZE|TYPE:|LABEL:|MOUNT/ =~ line

              line.split(/:|\s\s/).reject(&:empty?)
            end

            lsl_content.flatten!.select! { |elem| elem }.map! { |elem| elem.delete("\s") }

            Hash[*lsl_content]
          end

          def compute_size(info_hash)
            physical_partitions = info_hash['PPs'].to_i
            size_physical_partition = info_hash['PPSIZE']
            exp = size_physical_partition[/mega/] ? MEGABYTES_EXPONENT : GIGABYTES_EXPONENT
            size_physical_partition.to_i * physical_partitions * exp
          end
        end
      end
    end
  end
end
