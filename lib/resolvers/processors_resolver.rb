# frozen_string_literal: true

module Facter
  module Resolvers
    module Linux
      class Processors < BaseResolver
        @log = Facter::Log.new
        @semaphore = Mutex.new
        @fact_list ||= {}
        class << self
          # :count
          # :models
          # :physical_count
          def resolve(fact_name)
            @semaphore.synchronize do
              result ||= @fact_list[fact_name]
              subscribe_to_manager
              result || read_cpuinfo(fact_name)
            end
          end

          private

          def read_cpuinfo(fact_name)
            cpuinfo_output = File.read('/proc/cpuinfo')
            read_processors(cpuinfo_output) # + model names

            @fact_list[:physical_count] = @fact_list[:physical_processors].uniq.length
            @fact_list[fact_name]
          end

          def read_processors(cpuinfo_output)
            @fact_list[:processors] = 0
            @fact_list[:models] = []
            @fact_list[:physical_processors] = []
            cpuinfo_output.each_line do |line|
              tokens = line.split(':')
              count_processors(tokens)
              construct_models_list(tokens)
              count_physical_processors(tokens)
            end
          end

          def count_processors(tokens)
            @fact_list[:processors] += 1 if tokens.first.strip == 'processor'
          end

          def construct_models_list(tokens)
            @fact_list[:models] << tokens.last.strip if tokens.first.strip == 'model name'
          end

          def count_physical_processors(tokens)
            @fact_list[:physical_processors] << tokens.last.strip.to_i if tokens.first.strip == 'physical id'
          end
        end
      end
    end
  end
end
