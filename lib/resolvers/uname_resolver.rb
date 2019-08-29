# frozen_string_literal: true

class UnameResolver < BaseResolver
  class << self
    @@semaphore = Mutex.new
    @@fact_list ||= {}

    def resolve(fact_name)
      @@semaphore.synchronize do
        result ||= @@fact_list[fact_name]
        result || uname_system_call(fact_name)
      end
    end

    private

    def uname_system_call(fact_name)
      output, _status = Open3.capture2('uname -a')
      build_fact_list(output)
      @@fact_list[fact_name]
    end

    def build_fact_list(output)
      version = output.match(/\d{1,2}\.\d{1,2}\.\d{1,2}/).to_s
      output_strings = output.split(' ')

      @@fact_list[:release] = version
      @@fact_list[:name] = output_strings[0]
      @@fact_list[:family] = output_strings[0]
      @@fact_list[:architecture] = output_strings[-1]
      @@fact_list[:hardware] = output_strings[-1]
    end
  end
end
