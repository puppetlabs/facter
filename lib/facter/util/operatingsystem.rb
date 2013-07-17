
module Facter
module Util
module Operatingsystem

  OPERATINGSYSTEM_FILES = {
    "/etc/openwrt_release"     => "OpenWrt",
    "/etc/gentoo-release"      => "Gentoo",
    "/etc/fedora-release"      => "Fedora",
    "/etc/mandriva-release"    => "Mandriva",
    "/etc/mandrake-release"    => "Mandrake",
    "/etc/meego-release"       => "MeeGo",
    "/etc/arch-release"        => "Archlinux",
    "/etc/oracle-release"      => "OracleLinux",
    "/etc/vmware-release"      => "VMWareESX",
    "/etc/bluewhite64-version" => "Bluewhite64",
    "/etc/slamd64-version"     => "Slamd64",
    "/etc/slackware-version"   => "Slackware",
    "/etc/alpine-release"      => "Alpine",
    "/etc/mageia-release"      => "Mageia",
    "/etc/system-release"      => "Amazon",
  }

  REDHAT_VARIANTS = {
      /centos/i      => "CentOS",
      /CERN/         => "SLC",
      /scientific/i  => "Scientific",
      /^cloudlinux/i => "CloudLinux",
      /Ascendos/i    => "Ascendos",
      /^XenServer/i  => "XenServer",
      /XCP/          => "XCP",
      /^Parallels Server Bare Metal/i => "PSBM",
  }

  SUSE_VARIANTS = {
    /^SUSE LINUX Enterprise Server/i  => "SLES",
    /^SUSE LINUX Enterprise Desktop/i => "SLED",
    /^openSUSE/i                      => "OpenSuSE",
  }

  def release_by_file(path, candidates)
    str = File.read(path)

    key = candidates.keys.find do |variant_regex|
      str.match(variant_regex)
    end

    candidates[key]
  end

  module_function :release_by_file
end
end
end
