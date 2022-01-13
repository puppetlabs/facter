# frozen_string_literal: true

module Facter
  module Resolvers
    module Linux
      class Disks < BaseResolver
        @log = Facter::Log.new(self)

        init_resolver

        DIR = '/sys/block'
        FILE_PATHS = { model: 'device/model',
                       size: 'size',
                       vendor: 'device/vendor',
                       type: 'queue/rotational',
                       serial: 'false',
                       wwn: 'false' }.freeze

        class << self
          private

          def post_resolve(fact_name, _options)
            @fact_list.fetch(fact_name) do
              return unless @fact_list.empty?

              build_disks_hash

              read_facts

              @fact_list[:disks] = nil if @fact_list[:disks].empty?
              @fact_list[fact_name]
            end
          end

          def lsblk(option, disk)
            result = Facter::Core::Execution.execute(
              "lsblk -dn -o #{option} /dev/#{disk}", on_fail: '', timeout: 1
            ).strip
            result.empty? ? nil : result
          end

          def read_facts
            FILE_PATHS.each do |key, file|
              @fact_list[:disks].each do |disk, value|
                file_path = File.join(DIR, disk, file)

                result = if file == 'false'
                           lsblk(key, disk)
                         else
                           Facter::Util::FileHelper.safe_read(file_path, nil)&.strip
                         end

                next unless result

                value[key] = case key
                             when :size
                               # Linux always considers sectors to be 512 bytes long
                               # independently of the devices real block size.
                               construct_size(value, result)
                             when :type
                               result == '0' ? 'ssd' : 'hdd'
                             else
                               result
                             end
              end
            end
          end

          def build_disks_hash
            valid_disks = Facter::Util::FileHelper.dir_children(DIR)
                                                  .select { |disk| File.readable?(File.join(DIR, disk, 'device')) }

            @fact_list[:disks] = {}
            valid_disks.each { |disk| @fact_list[:disks][disk] = {} }
          end

          def construct_size(facts, value)
            value = value.to_i * 512
            facts[:size_bytes] = value
            facts[:size] = Facter::Util::Facts::UnitConverter.bytes_to_human_readable(value)
          end
        end
      end
    end
  end
end
