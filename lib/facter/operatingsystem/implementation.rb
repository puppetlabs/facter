require 'facter/operatingsystem/base'
require 'facter/operatingsystem/osreleaselinux'
require 'facter/operatingsystem/cumuluslinux'
require 'facter/operatingsystem/linux'
require 'facter/operatingsystem/sunos'
require 'facter/operatingsystem/vmkernel'
require 'facter/operatingsystem/windows'

module Facter
  module Operatingsystem
    def self.implementation(kernel = Facter.value(:kernel))
      case kernel
      when "Linux", "GNU/kFreeBSD"
        release_info = Facter::Util::Operatingsystem.os_release
        if release_info['NAME'] == "Cumulus Linux"
          Facter::Operatingsystem::CumulusLinux.new
        elsif release_info['NAME'] == "CoreOS"
          Facter::Operatingsystem::OsReleaseLinux.new
        else
          Facter::Operatingsystem::Linux.new
        end
      when "SunOS"
        Facter::Operatingsystem::SunOS.new
      when "VMkernel"
        Facter::Operatingsystem::VMkernel.new
      when "windows"
        Facter::Operatingsystem::Windows.new
      else
        Facter::Operatingsystem::Base.new
      end
    end
  end
end
