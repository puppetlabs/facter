# frozen_string_literal: true

class UnameResolver < BaseResolver
  class << self
    # rubocop:disable Style/ClassVars
    @@semaphore = Mutex.new
    @@fact_list ||= {}
    # rubocop:enable Style/ClassVars

    def resolve(fact_name)
      @@semaphore.synchronize do
        result ||= @@fact_list[fact_name]

        return result unless result.nil?

        output, _status = Open3.capture2('uname -a')
        version = output.match(/\d{1,2}\.\d{1,2}\.\d{1,2}/).to_s
        output_strings = output.split(' ')
        family = output_strings[0]
        architecture = output_strings[-1]
        hardware = output_strings[-1]

        @@fact_list[:name] = family
        @@fact_list[:family] = family
        @@fact_list[:release] = version
        @@fact_list[:architecture] = architecture
        @@fact_list[:hardware] = hardware

        return @@fact_list[fact_name]
      end
    end
  end
end
