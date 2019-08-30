# frozen_string_literal: true

require 'win32ole'

class Win32Ole
  RPC_C_IMP_LEVEL_IMPERSONATE = 3

  def initialize
    locator = WIN32OLE.new('WbemScripting.SWbemLocator')
    @conn = locator.ConnectServer('.', 'root\\cimv2')
    @conn.Security_.ImpersonationLevel = RPC_C_IMP_LEVEL_IMPERSONATE
  end

  def exec_query(query)
    @conn.execquery(query)
  end
end
