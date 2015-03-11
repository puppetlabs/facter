require 'facter/util/operatingsystem'
require 'facter/operatingsystem/linux'

module Facter
  module Operatingsystem
    class OsReleaseLinux < Linux
      def get_operatingsystem
        # Native cfacter also uses the NAME field.
        Facter::Util::Operatingsystem.os_release['NAME']
      end

      def get_osfamily
        Facter::Util::Operatingsystem.os_release['NAME']
      end

      def get_operatingsystemrelease
        @operatingsystemrelease ||= Facter::Util::Operatingsystem.os_release['VERSION_ID']
        @operatingsystemrelease
      end

      def get_operatingsystemmajrelease
        if operatingsystemrelease = get_operatingsystemrelease
          operatingsystemrelease.split(".").first
        end
      end
    end
  end
end
