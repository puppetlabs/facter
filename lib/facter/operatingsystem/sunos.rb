require 'facter/util/file_read'
require 'facter/operatingsystem/base'

module Facter
  module Operatingsystem
    class SunOS < Base
      def get_operatingsystem
        output = Facter::Core::Execution.exec('uname -v')
        if output =~ /^joyent_/
          "SmartOS"
        elsif output =~ /^oi_/
          "OpenIndiana"
        elsif output =~ /^omnios-/
          "OmniOS"
        elsif FileTest.exists?("/etc/debian_version")
          "Nexenta"
        else
          "Solaris"
        end
      end

      def get_osfamily
        "Solaris"
      end

      def get_operatingsystemrelease
        if release = Facter::Util::FileRead.read('/etc/release')
          line = release.split("\n").first

          # Solaris 10: Solaris 10 10/09 s10x_u8wos_08a X86
          # Solaris 11 (old naming scheme): Oracle Solaris 11 11/11 X86
          # Solaris 11 (new naming scheme): Oracle Solaris 11.1 SPARC
          if match = /\s+s(\d+)[sx]?(_u\d+)?.*(?:SPARC|X86)/.match(line)
            match.captures.join('')
          elsif match = /Solaris ([0-9\.]+(?:\s*[0-9\.\/]+))\s*(?:SPARC|X86)/.match(line)
            match.captures[0]
          else
            Facter[:kernelrelease].value
          end
        else
          Facter[:kernelrelease].value
        end
      end

      def get_operatingsystemmajorrelease
        if get_operatingsystem == "Solaris"
          if match = get_operatingsystemrelease.match(/^(\d+)/)
            match.captures[0]
          end
        end
      end
    end
  end
end
