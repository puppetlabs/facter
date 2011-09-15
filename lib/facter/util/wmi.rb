module Facter::Util::WMI
  class << self
    def connect(uri = wmi_resource_uri)
      require 'win32ole'
      WIN32OLE.connect(uri)
    end

    def wmi_resource_uri( host = '.' )
      "winmgmts:{impersonationLevel=impersonate}!//#{host}/root/cimv2"
    end

    def execquery(query)
      connect().execquery(query)
    end
  end
end
