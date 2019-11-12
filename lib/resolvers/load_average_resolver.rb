# frozen_string_literal: true

module Facter
  module Resolvers
    module Linux
      class LoadAverage < BaseResolver
        @log = Facter::Log.new
        @semaphore = Mutex.new
        @fact_list ||= {}
        class << self
          # :loadavrg
          def resolve(fact_name)
            @semaphore.synchronize do
              result ||= @fact_list[fact_name]
              result || read_loadavrg_file(fact_name)
            end
          end

          private

          def read_loadavrg_file(fact_name)
            output = File.read('/proc/loadavg')
            averages = output.split(' ')
            load_avrg = {}
            load_avrg.store('1min', averages[0])
            load_avrg.store('5min', averages[1])
            load_avrg.store('15min', averages[2])
            @fact_list[:loadavrg] = load_avrg
            @fact_list[fact_name]
          end
        end
      end
    end
  end
end
