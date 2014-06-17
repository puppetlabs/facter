module Facter
module Util
module Operatingsystem

  OPERATINGSYSTEM_FILES = {
    "/etc/openwrt_release"     => "OpenWrt",
    "/etc/gentoo-release"      => "Gentoo",
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
    /centos/i                       => "CentOS",
    /scientific linux CERN/i        => "SLC",
    /scientific linux release/i     => "Scientific",
    /^cloudlinux/i                  => "CloudLinux",
    /Ascendos/i                     => "Ascendos",
    /^XenServer/i                   => "XenServer",
    /XCP/                           => "XCP",
    /^Parallels Server Bare Metal/i => "PSBM",
    /^Fedora release/               => "Fedora",
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

  # @see http://www.freedesktop.org/software/systemd/man/os-release.html
  def self.os_release(file = '/etc/os-release')
    values = {}

    if File.readable?(file)
      File.readlines(file).each do |line|
        if (match = line.match(/^(\w+)=["']?(.+?)["']?$/))
          values[match[1]] = match[2]
        end
      end
    end

    values
  end
end
end
end
