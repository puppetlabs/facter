require 'facter/operatingsystem/base'

module Facter
  module Operatingsystem
    class Windows < Base
      def get_operatingsystemrelease
        require 'facter/util/wmi'
        result = nil
        Facter::Util::WMI.execquery("SELECT version, producttype FROM Win32_OperatingSystem").each do |os|
          result =
            case os.version
            when /^6\.4/
              # As of October 2014, there are no Win server releases with kernel 6.4.x.
              # This case prevents future releases from resolving to nil before we
              # can update the fact regexes.
              os.producttype == 1 ? "10" : Facter[:kernelrelease].value
            when /^6\.3/
              os.producttype == 1 ? "8.1" : "2012 R2"
            when /^6\.2/
              os.producttype == 1 ? "8" : "2012"
            when /^6\.1/
              os.producttype == 1 ? "7" : "2008 R2"
            when /^6\.0/
              os.producttype == 1 ? "Vista" : "2008"
            when /^5\.2/
              if os.producttype == 1
                "XP"
              else
                begin
                  os.othertypedescription == "R2" ? "2003 R2" : "2003"
                rescue NoMethodError
                  "2003"
                end
              end
            else
              Facter[:kernelrelease].value
            end
          break
        end
        result
      end
    end
  end
end
