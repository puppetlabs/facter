# frozen_string_literal: true

class ArchitectureResolver < BaseResolver
  # :architecture

  class << self
    @@semaphore = Mutex.new
    @@fact_list ||= {}

    def resolve(fact_name)
      @@semaphore.synchronize do
        result ||= @@fact_list[fact_name]
        result || read_architecture(fact_name)
      end
    end

    def read_architecture(fact_name)
      odmquery = Facter::ODMQuery.new
      odmquery
        .equals('name', 'proc0')
        .equals('attribute', 'type')

      result = odmquery.execute

      result.each_line do |line|
        if line.include?('value')
          @@fact_list[:architecture] = line.split('=')[1].strip.delete('\"')
          break
        end
      end

      @@fact_list[fact_name]
    end
  end
end
