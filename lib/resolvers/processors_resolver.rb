# frozen_string_literal: true

module Facter
  module Resolvers
    module Linux
      class Processors < BaseResolver
        @log = Facter::Log.new(self)
        @semaphore = Mutex.new
        @fact_list ||= {}
        class << self
          # :count
          # :models
          # :physical_count

          private

          def post_resolve(fact_name)
            @fact_list.fetch(fact_name) { read_cpuinfo(fact_name) }
          end

          def read_cpuinfo(fact_name)
            cpuinfo_output = Util::FileHelper.safe_readlines('/proc/cpuinfo')
            return if cpuinfo_output.empty?

            read_processors(cpuinfo_output) # + model names

            @fact_list[:physical_count] = @fact_list[:physical_processors].uniq.length
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
