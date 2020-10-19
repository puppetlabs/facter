# frozen_string_literal: true

module Facter
  module Resolvers
    module Linux
      class Processors < BaseResolver
        @log = Facter::Log.new(self)

        @semaphore = Mutex.new
        @fact_list ||= {}

        MHZ_TO_HZ = 1_000_000

        class << self
          # :count
          # :models
          # :physical_count
          # :speed

          private

          def post_resolve(fact_name)
            @fact_list.fetch(fact_name) { read_cpuinfo(fact_name) }
          end

          def read_cpuinfo(fact_name)
            cpuinfo_output = Util::FileHelper.safe_readlines('/proc/cpuinfo')
            return if cpuinfo_output.empty?

            read_processors(cpuinfo_output) # + model names

            @fact_list[:physical_count] = @fact_list[:physical_processors].uniq.length
            @fact_list[:physical_count] = physical_devices_count if @fact_list[:physical_count].zero?
            @fact_list[fact_name]
          end

          def read_processors(cpuinfo_output)
            @fact_list[:processors] = 0
            @fact_list[:models] = []
            @fact_list[:physical_processors] = []
            cpuinfo_output.each do |line|
              tokens = line.split(':')
              count_processors(tokens)
              construct_models_list(tokens)
              count_physical_processors(tokens)
              build_speed(tokens)
            end
          end

          def count_processors(tokens)
            @fact_list[:processors] += 1 if tokens.first.strip == 'processor'
          end

          def construct_models_list(tokens)
            return unless tokens.first.strip == 'model name' || tokens.first.strip == 'cpu'

            @fact_list[:models] << tokens.last.strip
          end

          def count_physical_processors(tokens)
            @fact_list[:physical_processors] << tokens.last.strip.to_i if tokens.first.strip == 'physical id'
          end

          def physical_devices_count
            Dir.entries('/sys/devices/system/cpu')
               .select { |dir| dir =~ /cpu[0-9]+$/ }
               .select { |dir| File.exist?("/sys/devices/system/cpu/#{dir}/topology/physical_package_id") }
               .map do |dir|
              Util::FileHelper.safe_read("/sys/devices/system/cpu/#{dir}/topology/physical_package_id").strip
            end
               .uniq.count
          end

          def build_speed(tokens)
            build_speed_for_power_pc(tokens) if tokens.first.strip == 'clock'
            build_speed_for_x86(tokens) if tokens.first.strip == 'cpu MHz'
          end

          def build_speed_for_power_pc(tokens)
            speed = tokens.last.strip.match(/^(\d+).*MHz/)[1]
            @fact_list[:speed] = speed.to_i * MHZ_TO_HZ
          end

          def build_speed_for_x86(tokens)
            speed = tokens.last.strip.match(/^(\d+).*/)[1]
            @fact_list[:speed] = speed.to_i * MHZ_TO_HZ
          end
        end
      end
    end
  end
end
