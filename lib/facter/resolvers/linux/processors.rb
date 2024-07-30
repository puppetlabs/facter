# frozen_string_literal: true

require 'set'

module Facter
  module Resolvers
    module Linux
      class Processors < BaseResolver
        init_resolver

        MHZ_TO_HZ = 1_000_000

        class << self
          # :count
          # :extensions
          # :models
          # :physical_count
          # :speed

          private

          def post_resolve(fact_name, _options)
            @fact_list.fetch(fact_name) { read_cpuinfo(fact_name) }
          end

          def read_cpuinfo(fact_name)
            cpuinfo_output = Facter::Util::FileHelper.safe_readlines('/proc/cpuinfo')
            return if cpuinfo_output.empty?

            read_processors(cpuinfo_output) # + model names

            @fact_list[:physical_count] = @fact_list[:physical_processors].uniq.length
            @fact_list[:physical_count] = physical_devices_count if @fact_list[:physical_count].zero?
            @fact_list[fact_name]
          end

          def read_processors(cpuinfo_output)
            @fact_list[:extensions] = Set[Facter::Resolvers::Uname.resolve(:processor)]
            @fact_list[:processors] = 0
            @fact_list[:models] = []
            @fact_list[:physical_processors] = []
            cpuinfo_output.each do |line|
              tokens = line.split(':')
              count_processors(tokens)
              construct_models_list(tokens)
              count_physical_processors(tokens)
              build_speed(tokens)
              check_extensions(tokens)
            end
            @fact_list[:extensions] = @fact_list[:extensions].to_a
            @fact_list[:extensions].sort!
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
              Facter::Util::FileHelper.safe_read("/sys/devices/system/cpu/#{dir}/topology/physical_package_id").strip
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

          def check_extensions(tokens)
            return unless tokens.first.strip == 'flags'

            flags = tokens.last.split(' ')

            # TODO: As we gain support for other arches, change the guard
            # so we only check the flags for the corosponding arches
            return unless @fact_list[:extensions].include?('x86_64')

            @fact_list[:extensions].add('x86_64-v1') if (%w[cmov cx8 fpu fxsr lm mmx syscall sse2] - flags).empty?
            @fact_list[:extensions].add('x86_64-v2') if (%w[cx16 lahf_lm popcnt sse4_1 sse4_2 ssse3] - flags).empty?
            @fact_list[:extensions].add('x86_64-v3') if (%w[abm avx avx2 bmi1 bmi2 f16c fma movbe xsave] - flags).empty?
            @fact_list[:extensions].add('x86_64-v4') if (%w[avx512f avx512bw avx512cd avx512dq avx512vl] - flags).empty?
          end
        end
      end
    end
  end
end
