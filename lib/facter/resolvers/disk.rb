# frozen_string_literal: true

module Facter
  module Resolvers
    module Linux
      class Disk < BaseResolver
        @log = Facter::Log.new(self)

        init_resolver

        DIR = '/sys/block'
        FILE_PATHS = { model: 'device/model', size: 'size', vendor: 'device/vendor', type: 'queue/rotational' }.freeze

        class << self
          private

          def post_resolve(fact_name)
            @fact_list.fetch(fact_name) { read_facts(fact_name) }
          end

          def read_facts(fact_name)
            build_disks_hash

            FILE_PATHS.each do |key, file|
              @fact_list[:disks].each do |disk, value|
                file_path = File.join(DIR, disk, file)

                result = Facter::Util::FileHelper.safe_read(file_path).strip
                next if result.empty?

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

            @fact_list[:disks] = nil if @fact_list[:disks].empty?
            @fact_list[fact_name]
          end

          def build_disks_hash
            @fact_list[:disks] = {}
            directories = Dir.entries(DIR).reject { |dir| dir =~ /\.+/ }
            directories.each { |disk| @fact_list[:disks].merge!(disk => {}) }
            @fact_list[:disks].select! { |disk, _fact| File.readable?(File.join(DIR, disk, 'device')) }
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
