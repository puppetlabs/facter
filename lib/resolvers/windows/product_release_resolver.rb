# frozen_string_literal: true

require 'win32/registry'

module Facter
  module Resolvers
    class ProductRelease < BaseResolver
      @semaphore = Mutex.new
      @fact_list ||= {}
      class << self
        def resolve(fact_name)
          @semaphore.synchronize do
            result ||= @fact_list[fact_name]
            subscribe_to_manager
            result || read_fact_from_registry(fact_name)
          end
        end

        private

        def read_fact_from_registry(fact_name)
          reg = ::Win32::Registry::HKEY_LOCAL_MACHINE.open('SOFTWARE\\Microsoft\\Windows NT\\CurrentVersion')
          build_fact_list(reg)
          reg.close

          @fact_list[fact_name]
        end

        def build_fact_list(reg)
          reg.each do |name, _value|
            @fact_list[:edition_id] = reg[name] if name == 'EditionID'
            @fact_list[:installation_type] = reg[name] if name == 'InstallationType'
            @fact_list[:product_name] = reg[name] if name == 'ProductName'
            @fact_list[:release_id] = reg[name] if name == 'ReleaseId'
          end
        end
      end
    end
  end
end
