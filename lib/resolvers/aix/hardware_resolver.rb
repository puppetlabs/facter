# frozen_string_literal: true

module Facter
  module Resolvers
    class HardwareResolver < BaseResolver
      # :hardware

      class << self
        @@semaphore = Mutex.new
        @@fact_list ||= {}

        def resolve(fact_name)
          @@semaphore.synchronize do
            result ||= @@fact_list[fact_name]
            subscribe_to_manager
            result || read_hardware(fact_name)
          end
        end

        def read_hardware(fact_name)
          odmquery = Facter::ODMQuery.new
          odmquery
            .equals('name', 'sys0')
            .equals('attribute', 'modelname')

          result = odmquery.execute

          result.each_line do |line|
            if line.include?('value')
              @@fact_list[:hardware] = line.split('=')[1].strip.delete('\"')
              break
            end
          end

          @@fact_list[fact_name]
        end
      end
    end
  end
end
