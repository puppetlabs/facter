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
require 'facter/util/file_read'

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

# Resolution for Debian variants.
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
  has_weight 10
  setcode do
    if FileTest.exists? '/etc/debian_version'
      if Facter.value(:lsbdistid) == "Ubuntu"
         "Ubuntu"
      elsif Facter.value(:lsbdistid) == "LinuxMint"
        "LinuxMint"
      else
        "Debian"
      end
    end
  end
end

# Resolution for Cumulus Linux (Debian variant)
Facter.add(:operatingsystem) do
  confine :kernel => :linux
  has_weight 11 # Should go before Debian
  setcode do
    if FileTest.exists? '/etc/os-release'
      if release = Facter::Util::FileRead.read('/etc/os-release')
        if match = release.match(/^NAME=["']?(.+?)["']?$/)
            name = match[1].gsub(/[^a-zA-Z]/, '')
            name if name == 'CumulusLinux'
        end
      end
    end
  end
end

Facter.add(:operatingsystem) do
  confine :kernel => :linux
  has_weight 10
  setcode do
    fpath = '/etc/redhat-release'
    if FileTest.exists? fpath
      candidates = Facter::Util::Operatingsystem::REDHAT_VARIANTS
      variant = Facter::Util::Operatingsystem.release_by_file(fpath, candidates)
      variant || 'RedHat'
    end
  end
end

Facter.add(:operatingsystem) do
  confine :kernel => :linux
  has_weight 10
  setcode do
    if FileTest.exists? '/etc/enterprise-release'
      if FileTest.exists? '/etc/ovs-release'
        'OVS'
      else
        'OEL'
      end
    end
  end
end

Facter.add(:operatingsystem) do
  confine :kernel => :linux
  has_weight 10
  setcode do
    fpath = "/etc/SuSE-release"
    if FileTest.exists? fpath
      candidates = Facter::Util::Operatingsystem::SUSE_VARIANTS
      variant = Facter::Util::Operatingsystem.release_by_file(fpath, candidates)
      variant || 'SuSE'
    end
  end
end

Facter.add(:operatingsystem) do
  confine :kernel => :linux
  has_weight 5
  setcode do
    files = Facter::Util::Operatingsystem::OPERATINGSYSTEM_FILES

    key = files.keys.find do |release_file|
      FileTest.exists? release_file
    end

    files[key]
  end
end

Facter.add(:operatingsystem) do
  confine :kernel => "VMkernel"
  setcode { "ESXi" }
end

Facter.add(:operatingsystem) do
  # Default to just returning the kernel as the operating system
  setcode { Facter[:kernel].value }
end
