# frozen_string_literal: true

module Facter
  module Resolvers
    class System32 < BaseResolver
      init_resolver

      class << self
        private

        def post_resolve(fact_name, _options)
          @fact_list.fetch(fact_name) { retrieve_windows_binaries_path }
        end

        def retrieve_windows_binaries_path
          require_relative '../../../facter/resolvers/windows/ffi/system32_ffi'

          # Ruby < 3 returned env key/values based on the active code page
          # Ruby 3+ use UTF-8, see ruby/ruby@ca76337a00244635faa331afd04f4b75161ce6fb
          windows_path = if RUBY_VERSION.to_f < 3.0
                           ENV['SystemRoot']&.dup&.force_encoding(Encoding.default_external)
                         else
                           ENV['SystemRoot']
                         end

          if !windows_path || windows_path.empty?
            @log.debug 'Unable to find correct value for SystemRoot enviroment variable'
            return nil
          end

          bool_ptr = FFI::MemoryPointer.new(:win32_bool, 1)
          if System32FFI::IsWow64Process(System32FFI::GetCurrentProcess(), bool_ptr) == FFI::WIN32FALSE
            @log.debug 'IsWow64Process failed'
            return
          end

          @fact_list[:system32] = construct_path(bool_ptr, windows_path)
        rescue LoadError => e
          @log.debug("Could not retrieve: #{e}")
        end

        def construct_path(bool_ptr, windows)
          if bool_ptr.read_win32_bool
            "#{windows}\\sysnative"
          else
            "#{windows}\\system32"
          end
        end
      end
    end
  end
end
