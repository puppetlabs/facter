# frozen_string_literal: true

require 'win32/registry'

module Facter
  module Resolvers
    class ProductRelease < BaseResolver
      @semaphore = Mutex.new
      @fact_list ||= {}
      class << self
        private

        def post_resolve(fact_name)
          @fact_list.fetch(fact_name) { read_fact_from_registry(fact_name) }
        end

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
