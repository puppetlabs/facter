# frozen_string_literal: true

module Facter
  module Resolvers
    class WinOsDescription < BaseResolver
      @log = Facter::Log.new
      @semaphore = Mutex.new
      @fact_list ||= {}
      class << self
        def resolve(fact_name)
          @semaphore.synchronize do
            result ||= @fact_list[fact_name]
            subscribe_to_manager
            result || read_from_ole(fact_name)
          end
        end

        private

        def read_from_ole(fact_name)
          win = Win32Ole.new
          op_sys = win.return_first('SELECT ProductType,OtherTypeDescription FROM Win32_OperatingSystem')
          unless op_sys
            @log.debug 'WMI query returned no results for Win32_OperatingSystem'\
                       'with values ProductType and OtherTypeDescription.'
            return
          end
          @fact_list[:consumerrel] = (op_sys.ProductType == 1)
          @fact_list[:description] = op_sys.OtherTypeDescription
          @fact_list[fact_name]
        end
      end
    end
  end
end
