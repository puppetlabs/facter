# frozen_string_literal: true

module Facter
  module Resolvers
    module Linux
      class Disk < BaseResolver
        @log = Facter::Log.new(self)
        @semaphore = Mutex.new
        @fact_list ||= {}
        DIR = '/sys/block'
        FILE_PATHS = { model: 'device/model', size: 'size', vendor: 'device/vendor' }.freeze
        class << self
          private

          def post_resolve(fact_name)
            @fact_list.fetch(fact_name) { read_facts(fact_name) }
          end

          def read_facts(fact_name)
            @fact_list[:disks] = {}
            build_disks_hash

            FILE_PATHS.each do |key, file|
              @fact_list[:disks].each do |disk, value|
                file_path = File.join(DIR, disk, file)

                next unless File.readable?(file_path)

                result = File.read(file_path).strip

                # Linux always considers sectors to be 512 bytes long independently of the devices real block size.
                value[key] = file =~ /size/ ? result.to_i * 512 : result
              end
            end

            @fact_list[fact_name]
          end

          def build_disks_hash
            directories = Dir.entries(DIR).reject { |dir| dir =~ /\.+/ }
            directories.each { |disk| @fact_list[:disks].merge!(disk => {}) }
          end
        end
      end
    end
  end
end
