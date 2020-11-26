# frozen_string_literal: true

require 'win32ole'

module Facter
  module Util
    module Windows
      class Win32Ole
        RPC_C_IMP_LEVEL_IMPERSONATE = 3

        def initialize
          locator = WIN32OLE.new('WbemScripting.SWbemLocator')
          @conn = locator.ConnectServer('.', 'root\\cimv2')
          @conn.Security_.ImpersonationLevel = RPC_C_IMP_LEVEL_IMPERSONATE
        end

        def return_first(query)
          result = exec_query(query)
          return result.to_enum.first if result

          nil
        end

        def exec_query(query)
          @conn.execquery(query)
        end
      end
    end
  end
end
