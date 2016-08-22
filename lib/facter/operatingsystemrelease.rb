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
#
#   On all remaining systems, returns the 'kernelrelease' value.
#
# Caveats:
#

Facter.add(:operatingsystemrelease) do
  confine :operatingsystem => %w{CentOS Fedora oel ovs OracleLinux RedHat MeeGo Scientific SLC Ascendos CloudLinux PSBM}
  setcode do
    case Facter.value(:operatingsystem)
    when "CentOS", "RedHat", "Scientific", "SLC", "Ascendos", "CloudLinux", "PSBM"
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
    File::open(releasefile, "r") do |f|
      line = f.readline.chomp
      if line =~ /\(Rawhide\)$/
        "Rawhide"
      elsif line =~ /release (\d[\d.]*)/
        $1
      end
    end
  end
end

Facter.add(:operatingsystemrelease) do
  confine :operatingsystem => %w{Debian}
  setcode do
    release = Facter::Util::Resolution.exec('cat /etc/debian_version')
  end
end

Facter.add(:operatingsystemrelease) do
  confine :operatingsystem => %w{Ubuntu}
  setcode do
    release = Facter::Util::Resolution.exec('cat /etc/issue')
    if release =~ /Ubuntu (\d+.\d+)/
      $1
    end
  end
end

Facter.add(:operatingsystemrelease) do
  confine :operatingsystem => %w{SLES SLED openSUSE}
  setcode do
    releasefile = Facter::Util::Resolution.exec('cat /etc/SuSE-release')
    if releasefile =~ /^VERSION\s*=\s*(\d+)/
      releasemajor = $1
      if releasefile =~ /^PATCHLEVEL\s*=\s*(\d+)/
        releaseminor = $1
      elsif releasefile =~ /^VERSION\s=.*.(\d+)/
        releaseminor = $1
      else
        releaseminor = "0"
      end
      releasemajor + "." + releaseminor
    else
      "unknown"
    end
  end
end

Facter.add(:operatingsystemrelease) do
  confine :operatingsystem => %w{Slackware}
  setcode do
    release = Facter::Util::Resolution.exec('cat /etc/slackware-version')
    if release =~ /Slackware ([0-9.]+)/
      $1
    end
  end
end

Facter.add(:operatingsystemrelease) do
  confine :operatingsystem => %w{Bluewhite64}
  setcode do
    releasefile = Facter::Util::Resolution.exec('cat /etc/bluewhite64-version')
    if releasefile =~ /^\s*\w+\s+(\d+)\.(\d+)/
      $1 + "." + $2
    else
      "unknown"
    end
  end
end

Facter.add(:operatingsystemrelease) do
  confine :operatingsystem => %w{VMwareESX}
  setcode do
    release = Facter::Util::Resolution.exec('vmware -v')
    if release =~ /VMware ESX .*?(\d.*)/
      $1
    end
  end
end

Facter.add(:operatingsystemrelease) do
  confine :operatingsystem => %w{Slamd64}
  setcode do
    releasefile = Facter::Util::Resolution.exec('cat /etc/slamd64-version')
    if releasefile =~ /^\s*\w+\s+(\d+)\.(\d+)/
      $1 + "." + $2
    else
      "unknown"
    end
  end
end

Facter.add(:operatingsystemrelease) do
  confine :operatingsystem => :Alpine
  setcode do
    File.read('/etc/alpine-release')
  end
end

Facter.add(:operatingsystemrelease) do
  confine :operatingsystem => %W{Amazon}
  setcode do Facter[:lsbdistrelease].value end
end

Facter.add(:operatingsystemrelease) do
  setcode do Facter[:kernelrelease].value end
end
