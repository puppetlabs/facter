# frozen_string_literal: true

module Facter
  module Resolvers
    class Domain < BaseResolver
      @log = Facter::Log.new
      @semaphore = Mutex.new
      @fact_list ||= {}
      class << self
        def resolve(fact_name)
          @semaphore.synchronize do
            result ||= @fact_list[fact_name]
            subscribe_to_manager
            result || retrieve_domain
          end
        end

        private

        def retrieve_domain
          win = Win32Ole.new
          domain = nil
          result = win.exec_query('select DNSDomain from Win32_NetworkAdapterConfiguration where IPEnabled = True')
          unless result
            @log.debug 'WMI query returned no results for Win32_NetworkAdapterConfiguration with value DNSDomain.'
            return domain
          end
          result.each do |network|
            domain =  network.DNSDomain if network.DNSDomain && !network.DNSDomain.empty?
          end
          @fact_list[:domain] = domain
        end
      end
    end
  end
end
