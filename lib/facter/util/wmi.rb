module Facter::Util::WMI
  class << self

    # Impersonation Level Constants
    # https://msdn.microsoft.com/en-us/library/windows/desktop/ms693790%28v=vs.85%29.aspx
    RPC_C_IMP_LEVEL_DEFAULT       = 0
    RPC_C_IMP_LEVEL_ANONYMOUS     = 1
    RPC_C_IMP_LEVEL_IDENTIFY      = 2
    RPC_C_IMP_LEVEL_IMPERSONATE   = 3
    RPC_C_IMP_LEVEL_DELEGATE      = 4

    # returns a COM class implementing ISWbemServicesEx
    # prior to Facter 2.5.0, this defaulted to using a moniker
    # but now defaults to using COM classes directly to support Nano
    # backward compatibility is maintained in case custom facts specified a moniker
    # but note that passing in the uri parameter can never work on Nano
    def connect(uri = nil)
      require 'win32ole'
      uri.nil? ?
        connect2() :
        # NOTE: in the future it would be better to parse a given moniker uri / call connect2
        WIN32OLE.connect(uri)
    end

    # @deprecated
    def wmi_resource_uri( host = '.' )
      "winmgmts:{impersonationLevel=impersonate}!//#{host}/root/cimv2"
    end

    def execquery(query)
      connect().execquery(query)
    end

    private

    # this mimics the previous behavior of using the COM moniker
    # winmgmts:{impersonationLevel=impersonate}!//./root/cimv2
    # which is not supported on Nano Server
    def connect2( server = '.', namespace = 'root\\cimv2', impersonation_level = RPC_C_IMP_LEVEL_IMPERSONATE )
      locator = WIN32OLE.new("WbemScripting.SWbemLocator")
      # https://msdn.microsoft.com/en-us/library/aa393720%28v=vs.85%29.aspx
      # ConnectServer returns an ISWbemServicesEx
      conn = locator.ConnectServer(server, namespace)
      conn.Security_.ImpersonationLevel = impersonation_level
      conn
    end

  end
end
