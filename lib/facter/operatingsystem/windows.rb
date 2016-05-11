require 'facter/operatingsystem/base'

module Facter
  module Operatingsystem
    class Windows < Base
      def get_operatingsystemrelease
        require 'facter/util/windows'
        result = nil
        Facter::Util::Windows::Process.os_version do |os|
          result =
            case "#{os[:dwMajorVersion]}.#{os[:dwMinorVersion]}"
            when '10.0'
              if os[:dwBuildNumber] == 14300
                'Nano'
              else
                os[:wProductType] == 1 ? '10' : Facter[:kernelrelease].value
              end
            when '6.3'
              os[:wProductType] == 1 ? "8.1" : "2012 R2"
            when '6.2'
              os[:wProductType] == 1 ? "8" : "2012"
            when '6.1'
              os[:wProductType] == 1 ? "7" : "2008 R2"
            when '6.0'
              os[:wProductType] == 1 ? "Vista" : "2008"
            when '5.2'
              if os[:wProductType] == 1
                "XP"
              elsif Facter::Util::Windows::Process.is_2003_r2?
                "2003 R2"
              else
                "2003"
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
