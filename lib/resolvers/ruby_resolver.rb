# frozen_string_literal: true

class RubyResolver < BaseResolver
  class << self
    # Manufacturer
    # SerialNumber
    @@semaphore = Mutex.new
    @@fact_list ||= {}

    def resolve(fact_name)
      @@semaphore.synchronize do
        result ||= @@fact_list[fact_name]
        result || retrieve_ruby_information(fact_name)
      end
    end

    private

    def retrieve_ruby_information(fact_name)
      @@fact_list[:sitedir] = RbConfig::CONFIG['sitelibdir']
      @@fact_list[:platform] = RUBY_PLATFORM
      @@fact_list[:version] = RUBY_VERSION
      @@fact_list[fact_name]
    end
  end
end


