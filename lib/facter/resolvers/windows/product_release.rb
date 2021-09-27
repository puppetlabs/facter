# frozen_string_literal: true

require 'win32/registry'

module Facter
  module Resolvers
    class ProductRelease < BaseResolver
      init_resolver

      class << self
        private

        def post_resolve(fact_name, _options)
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
            case name
            when 'EditionID'
              @fact_list[:edition_id] = reg[name]
            when 'InstallationType'
              @fact_list[:installation_type] = reg[name]
            when 'ProductName'
              @fact_list[:product_name] = reg[name]
            when 'DisplayVersion'
              @fact_list[:release_id] = reg[name]
              @fact_list[:display_version] = reg[name]
            when 'ReleaseId'
              @fact_list[:release_id] = reg[name] unless @fact_list[:release_id]
            end
          end
        end
      end
    end
  end
end
