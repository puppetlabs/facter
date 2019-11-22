# frozen_string_literal: true

module Facter
  module Resolvers
    module Linux
      class Disk < BaseResolver
        @log = Facter::Log.new
        @semaphore = Mutex.new
        @fact_list ||= {}
        DIR = '/sys/block/'
        FILE_PATHS = { model: '/device/model', size: '/size', vendor: '/device/vendor' }.freeze
        class << self
          # :sr0_model
          # :sr0_size
          # :sr0_vendor
          # :sda_model
          # :sda_size
          # :sda_vendor

          def resolve(fact_name)
            @semaphore.synchronize do
              result ||= @fact_list[fact_name]
              subscribe_to_manager
              result || read_facts(fact_name)
            end
          end

          def read_facts(fact_name)
            file_path = compose_file_path(fact_name)
            return nil unless File.exist?(file_path)

            result = File.read(file_path).strip
            @fact_list[fact_name] = fact_name.to_s =~ /size/ ? result.to_i * 1024 : result
          end

          def compose_file_path(fact_name)
            block, file = fact_name.to_s.split('_')
            DIR + block + FILE_PATHS[file.to_sym]
          end
        end
      end
    end
  end
end
