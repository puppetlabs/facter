# Fact: operatingsystemrelease
#
# Purpose: Returns the release of the operating system.
#
# Resolution:
#   On RedHat derivatives, returns their '/etc/<variant>-release' file.
#   On Debian, returns '/etc/debian_version'.
#   On Ubuntu, parses '/etc/lsb-release' for the release version.
#   On Suse, derivatives, parses '/etc/SuSE-release' for a selection of version
#   information.
#   On Slackware, parses '/etc/slackware-version'.
#   On Amazon Linux, returns the 'lsbdistrelease' value.
#   On Mageia, parses '/etc/mageia-release' for the release version.
#
#   On all remaining systems, returns the 'kernelrelease' value.
#
# Caveats:
#

require 'facter/util/file_read'

Facter.add(:operatingsystemrelease) do
  confine :operatingsystem => %w{CentOS Fedora oel ovs OracleLinux RedHat MeeGo Scientific SLC Ascendos CloudLinux PSBM}
  setcode do
    case Facter.value(:operatingsystem)
    when "CentOS", "RedHat", "Scientific", "SLC", "Ascendos", "CloudLinux", "PSBM", "XenServer"
      releasefile = "/etc/redhat-release"
    when "Fedora"
      releasefile = "/etc/fedora-release"
    when "MeeGo"
      releasefile = "/etc/meego-release"
    when "OracleLinux"
      releasefile = "/etc/oracle-release"
    when "OEL", "oel"
      releasefile = "/etc/enterprise-release"
    when "OVS", "ovs"
      releasefile = "/etc/ovs-release"
    end

    if release = Facter::Util::FileRead.read(releasefile)
      line = release.split("\n").first.chomp
      if match = /\(Rawhide\)$/.match(line)
        "Rawhide"
      elsif match = /release (\d[\d.]*)/.match(line)
        match[1]
      end
    end
  end
end

{
  :Debian  => '/etc/debian_version',
  :Alpine => '/etc/alpine-release',
}.each do |platform, file_name|
  Facter.add(:operatingsystemrelease) do
    confine :operatingsystem => platform
    setcode do
      if release = Facter::Util::FileRead.read(file_name)
        release.sub!(/\s*$/, '')
        release
      end
    end
  end
end

Facter.add(:operatingsystemrelease) do
  confine :operatingsystem => %w{Ubuntu}
  setcode do
    if release = Facter::Util::FileRead.read('/etc/lsb-release')
      if match = release.match(/DISTRIB_RELEASE=((\d+.\d+)(\.(\d+))?)/)
        # Return only the major and minor version numbers.  This behavior must
        # be preserved for compatibility reasons.
        match[2]
      end
    end
  end
end

Facter.add(:operatingsystemrelease) do
  confine :operatingsystem => 'LinuxMint'
  setcode do
    if release = Facter::Util::FileRead.read('/etc/linuxmint/info')
      if match = release.match(/RELEASE\=(\d+)/)
        match[1]
      end
    end
  end
end

Facter.add(:operatingsystemrelease) do
  confine :operatingsystem => %w{SLES SLED OpenSuSE}
  setcode do
    if release = Facter::Util::FileRead.read('/etc/SuSE-release')
      if match = /^VERSION\s*=\s*(\d+)/.match(release)
        releasemajor = match[1]
        if match = /^PATCHLEVEL\s*=\s*(\d+)/.match(release)
          releaseminor = match[1]
        elsif match = /^VERSION\s=.*.(\d+)/.match(release)
          releaseminor = match[1]
        else
          releaseminor = "0"
        end
        releasemajor + "." + releaseminor
      else
        "unknown"
      end
    end
  end
end

{
  :OpenWrt => {
    :file => '/etc/openwrt_version',
    :regexp => /^(\d+\.\d+.*)/
  },
  :Slackware => {
    :file => '/etc/slackware-version',
    :regexp  => /Slackware ([0-9.]+)/
  },
  :Mageia => {
    :file => '/etc/mageia-release',
    :regexp => /Mageia release ([0-9.]+)/
  },
  :Bluewhite64 => {
    :file => '/etc/bluewhite64-version',
    :regexp => /^\s*\w+\s+(\d+\.\d+)/
  },
  :Slamd64 => {
    :file => '/etc/slamd64-version',
    :regexp => /^\s*\w+\s+(\d+\.\d+)/
  },
}.each do |platform, platform_data|
  Facter.add(:operatingsystemrelease) do
    confine :operatingsystem => platform
    setcode do
      if release = Facter::Util::FileRead.read(platform_data[:file])
        if match = platform_data[:regexp].match(release)
          match[1]
        end
      end
    end
  end
end

Facter.add(:operatingsystemrelease) do
  confine :operatingsystem => %w{VMwareESX}
  setcode do
    release = Facter::Util::Resolution.exec('vmware -v')
    if match = /VMware ESX .*?(\d.*)/.match(release)
      match[1]
    end
  end
end


Facter.add(:operatingsystemrelease) do
  confine :operatingsystem => %W{Amazon}
  setcode do Facter[:lsbdistrelease].value end
end

Facter.add(:operatingsystemrelease) do
  confine :osfamily => :solaris
  setcode do
    if release = Facter::Util::FileRead.read('/etc/release')
      line = release.split("\n").first.chomp
      if match = /\s+s(\d+)[sx]?(_u\d+)?.*(?:SPARC|X86)/.match(line)
        match.captures.join('')
      end
    end
  end
end

Facter.add(:operatingsystemrelease) do
  confine :operatingsystem => %w{CumulusLinux}
  setcode do
    if release = Facter::Util::FileRead.read('/etc/os-release')
      if match = /^VERSION_ID\s*=\s*(\d+\.\d+\.\d+)/.match(release)
        match[1]
      end
    end
  end
end

Facter.add(:operatingsystemrelease) do
  confine :operatingsystem => :windows
  setcode do
    require 'facter/util/wmi'
    result = nil
    Facter::Util::WMI.execquery("SELECT version, producttype FROM Win32_OperatingSystem").each do |os|
      result =
        case os.version
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
            os.othertypedescription == "R2" ? "2003 R2" : "2003"
          end
        else
          Facter[:kernelrelease].value
        end
      break
    end
    result
  end
end

Facter.add(:operatingsystemrelease) do
  setcode do Facter[:kernelrelease].value end
end
