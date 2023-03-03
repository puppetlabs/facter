# frozen_string_literal: true

module Facter
  module Resolvers
    module Windows
      class Timezone < BaseResolver
        init_resolver

        class << self
          private

          def post_resolve(fact_name, _options)
            @fact_list.fetch(fact_name) { determine_timezone }
          end

          def determine_timezone
            timezone = Time.now.zone
            @fact_list[:timezone] = timezone.force_encoding("CP#{codepage}").encode('UTF-8', invalid: :replace)
          rescue ArgumentError
            @fact_list[:timezone] = timezone
          end

          def codepage
            result = codepage_from_api
            result.empty? ? codepage_from_registry : result
          end

          def codepage_from_registry
            require 'win32/registry'
            ::Win32::Registry::HKEY_LOCAL_MACHINE.open('SYSTEM\CurrentControlSet\Control\Nls\CodePage')['ACP']
          end

          def codepage_from_api
            require_relative '../../../facter/resolvers/windows/ffi/winnls_ffi'
            WinnlsFFI.GetACP.to_s
          end
        end
      end
    end
  end
end
