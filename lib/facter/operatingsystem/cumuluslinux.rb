require 'facter/util/operatingsystem'
require 'facter/operatingsystem/linux'

module Facter
  module Operatingsystem
    class CumulusLinux < Linux
      def get_operatingsystem
        "CumulusLinux"
      end

      def get_osfamily
        "Debian"
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
