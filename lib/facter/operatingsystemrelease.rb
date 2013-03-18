# Fact: operatingsystemrelease
#
# Purpose: Returns the release of the operating system.
#
# Resolution:
#   On RedHat derivatives, returns their '/etc/<variant>-release' file.
#   On Debian, returns '/etc/debian_version'.
#   On Ubuntu, parses '/etc/issue' for the release version.
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

Facter.add(:operatingsystemrelease) do
  confine :operatingsystem => %w{Debian}
  setcode do
    if release = Facter::Util::FileRead.read('/etc/debian_version')
      release.sub!(/\s*$/, '')
      release
    end
  end
end

Facter.add(:operatingsystemrelease) do
  confine :operatingsystem => %w{Ubuntu}
  setcode do
    if release = Facter::Util::FileRead.read('/etc/issue')
      if match = release.match(/Ubuntu ((\d+.\d+)(\.(\d+))?)/)
        # Return only the major and minor version numbers.  This behavior must
        # be preserved for compatibility reasons.
        match[2]
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

Facter.add(:operatingsystemrelease) do
  confine :operatingsystem => %w{OpenWrt}
  setcode do
    if release = Facter::Util::FileRead.read('/etc/openwrt_version')
      if match = /^(\d+\.\d+.*)/.match(release)
        match[1]
      end
    end
  end
end

Facter.add(:operatingsystemrelease) do
  confine :operatingsystem => %w{Slackware}
  setcode do
    if release = Facter::Util::FileRead.read('/etc/slackware-version')
      if match = /Slackware ([0-9.]+)/.match(release)
        match[1]
      end
    end
  end
end

Facter.add(:operatingsystemrelease) do
  confine :operatingsystem => %w{Mageia}
  setcode do
    if release = Facter::Util::FileRead.read('/etc/mageia-release')
      if match = /Mageia release ([0-9.]+)/.match(release)
        match[1]
      end
    end
  end
end

Facter.add(:operatingsystemrelease) do
  confine :operatingsystem => %w{Bluewhite64}
  setcode do
    if release = Facter::Util::FileRead.read('/etc/bluewhite64-version')
      if match = /^\s*\w+\s+(\d+)\.(\d+)/.match(release)
        match[1] + "." + match[2]
      else
        "unknown"
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
  confine :operatingsystem => %w{Slamd64}
  setcode do
    if release = Facter::Util::FileRead.read('/etc/slamd64-version')
      if match = /^\s*\w+\s+(\d+)\.(\d+)/.match(release)
        match[1] + "." + match[2]
      else
        "unknown"
      end
    end
  end
end

Facter.add(:operatingsystemrelease) do
  confine :operatingsystem => :Alpine
  setcode do
    if release = Facter::Util::FileRead.read('/etc/alpine-release')
      release.sub!(/\s*$/, '')
      release
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
  setcode do Facter[:kernelrelease].value end
end
