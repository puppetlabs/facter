# Fact: os
#
# Purpose:
#   Return various facts related to the machine's operating system.
#
# Resolution:
#   For operatingsystem, if the kernel is a Linux kernel, check for the
#   existence of a selection of files in `/etc` to find the specific flavor.
#   On SunOS based kernels, attempt to determine the flavor, otherwise return Solaris.
#   On systems other than Linux, use the kernel value.
#
#   For operatingsystemrelease, on RedHat derivatives, we return their `/etc/<varient>-release` file.
#   On Debian, returns `/etc/debian_version`.
#   On Ubuntu, parses `/etc/lsb-release` for the release version
#   On Suse and derivatives, parses `/etc/SuSE-release` for a selection of version information.
#   On Slackware, parses `/etc/slackware-version`.
#   On Amazon Linux, returns the lsbdistrelease fact's value.
#   On Mageia, parses `/etc/mageia-release` for the release version.
#   On all remaining systems, returns the kernelrelease fact's value.
#
#   For the lsb facts, uses the `lsb_release` system command.
#
# Caveats:
#   Lsb facts only work on Linux (and the kfreebsd derivative) systems.
#   Requires the `lsb_release` program, which may not be installed by default.
#   It is only as accurate as the ourput of lsb_release.
#

require 'facter/operatingsystem/implementation'

Facter.add(:os, :type => :aggregate) do
  def os
    @os ||= Facter::Operatingsystem.implementation
  end

  chunk(:name) do
    os_hash = {}
    if (operatingsystem = os.get_operatingsystem)
      os_hash["name"] = operatingsystem
      os_hash
    end
  end

  chunk(:family) do
    os_hash = {}
    if (osfamily = os.get_osfamily)
      os_hash["family"] = osfamily
      os_hash
    end
  end

  chunk(:release) do
    os_hash = {}
    if (releasedata = os.get_operatingsystemrelease_hash)
      os_hash["release"] = releasedata
      os_hash unless os_hash["release"].empty?
    end
  end

  chunk(:lsb) do
    os_hash = {}
    if os.has_lsb?
      if (lsbdata = os.get_lsb_facts_hash)
        os_hash["lsb"] = lsbdata
        os_hash unless os_hash["lsb"].empty?
      end
    end
  end
end
