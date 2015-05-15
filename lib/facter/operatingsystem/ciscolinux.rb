require 'facter/util/ciscoos'
require 'facter/operatingsystem/linux'

module Facter
  module Operatingsystem
    class CiscoLinux < Linux

      def initialize(file)
        @cisco_info = Facter::Util::CiscoOS.cisco_release(file)
      end

      def get_operatingsystem
        @operatingsystem ||= @cisco_info['ID']
        @operatingsystem
      end

      def get_osfamily
        @osfamily ||= @cisco_info['ID_LIKE']
        @osfamily
      end

      def get_operatingsystemrelease
        @operatingsystemrelease ||= @cisco_info['VERSION']
        @operatingsystemrelease
      end

      def get_operatingsystemmajorrelease 
        if operatingsystemrelease = get_operatingsystemrelease
          operatingsystemrelease.split("(").first
        end
      end
    end
  end
end
