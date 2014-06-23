# Fact: operatingsystem
#
# Purpose: Return the name of the operating system.
#
# Resolution:
#   If the kernel is a Linux kernel, check for the existence of a selection of
#   files in /etc/ to find the specific flavour.
#   On SunOS based kernels, attempt to determine the flavour, otherwise return Solaris.
#   On systems other than Linux, use the kernel value.
#
# Caveats:
#

require 'facter/util/operatingsystem'

Facter.add(:operatingsystem) do
  confine :kernel => :sunos
  setcode do
    # Use uname -v because /etc/release can change in zones under SmartOS.
    # It's apparently not trustworthy enough to rely on for this fact.
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
end

Facter.add(:operatingsystem) do
  # Cumulus Linux is a variant of Debian so this resolution needs to come
  # before the Debian resolution.
  has_weight(10)
  confine :kernel => :linux

  setcode do
    release_info = Facter::Util::Operatingsystem.os_release
    if release_info['NAME'] == "Cumulus Linux"
      'CumulusLinux'
    end
  end
end

Facter.add(:operatingsystem) do
  confine :kernel => :linux
  setcode do
    if Facter.value(:lsbdistid) == "Ubuntu"
       "Ubuntu"
    elsif Facter.value(:lsbdistid) == "LinuxMint"
       "LinuxMint"
    elsif FileTest.exists?("/etc/debian_version")
      "Debian"
    elsif FileTest.exists?("/etc/openwrt_release")
      "OpenWrt"
    elsif FileTest.exists?("/etc/gentoo-release")
      "Gentoo"
    elsif FileTest.exists?("/etc/fedora-release")
      "Fedora"
    elsif FileTest.exists?("/etc/mageia-release")
      "Mageia"
    elsif FileTest.exists?("/etc/mandriva-release")
      "Mandriva"
    elsif FileTest.exists?("/etc/mandrake-release")
      "Mandrake"
    elsif FileTest.exists?("/etc/meego-release")
      "MeeGo"
    elsif FileTest.exists?("/etc/arch-release")
      "Archlinux"
    elsif FileTest.exists?("/etc/oracle-release")
      "OracleLinux"
    elsif FileTest.exists?("/etc/enterprise-release")
      if FileTest.exists?("/etc/ovs-release")
        "OVS"
      else
        "OEL"
      end
    elsif FileTest.exists?("/etc/vmware-release")
      "VMWareESX"
    elsif FileTest.exists?("/etc/redhat-release")
      txt = File.read("/etc/redhat-release")
      if txt =~ /centos/i
        "CentOS"
      elsif txt =~ /CERN/
        "SLC"
      elsif txt =~ /scientific/i
        "Scientific"
      elsif txt =~ /^cloudlinux/i
        "CloudLinux"
      elsif txt =~ /^Parallels Server Bare Metal/i
        "PSBM"
      elsif txt =~ /Ascendos/i
        "Ascendos"
      elsif txt =~ /^XenServer/i
        "XenServer"
      else
        "RedHat"
      end
    elsif FileTest.exists?("/etc/SuSE-release")
      txt = File.read("/etc/SuSE-release")
      if txt =~ /^SUSE LINUX Enterprise Server/i
        "SLES"
      elsif txt =~ /^SUSE LINUX Enterprise Desktop/i
        "SLED"
      elsif txt =~ /^openSUSE/i
        "OpenSuSE"
      else
        "SuSE"
      end
    elsif FileTest.exists?("/etc/bluewhite64-version")
      "Bluewhite64"
    elsif FileTest.exists?("/etc/slamd64-version")
      "Slamd64"
    elsif FileTest.exists?("/etc/slackware-version")
      "Slackware"
    elsif FileTest.exists?("/etc/alpine-release")
      "Alpine"
    elsif FileTest.exists?("/etc/mageia-release")
      "Mageia"
    elsif FileTest.exists?("/etc/system-release")
      "Amazon"
    end
  end
end

Facter.add(:operatingsystem) do
  confine :kernel => "VMkernel"
  setcode do
    "ESXi"
  end
end

Facter.add(:operatingsystem) do
  # Default to just returning the kernel as the operating system
  setcode do Facter[:kernel].value end
end
