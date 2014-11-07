# Fact: os
#
# Purpose:
#   Return various facts related to the machine's operating system, including:
#   Name: The name of the operating system.
#   Family: A mapping of the operating system to an operating system family.
#   Release: The release version of the operating system. Includes entries for the
#   major and minor release versions, as well as the full release string.
#   Lsb: Linux Standard Base information for the system.
#
#   This fact is structured. These values are returned as a group of key-value pairs.
#
# Resolution:
#   For the name entry, if the kernel is a Linux kernel, check for the existence of a 
#   selection of files in `/etc` to find the specific flavor.
#   On SunOS based kernels, attempt to determine the flavor, otherwise return Solaris.
#   On systems other than Linux, use the kernel value.
#
#   For the family entry, map operating systems to operating system families, such
#   as linux distribution derivatives. Adds mappings from specific operating systems
#   to kernels in the case that it is relevant.
#
#   For the release entry, on RedHat derivatives, returns `/etc/<variant>-release` file.
#   On Debian, returns `/etc/debian_version`.
#   On Ubuntu, parses `/etc/lsb-release` for the release version
#   On Suse and derivatives, parses `/etc/SuSE-release` for a selection of version
#   information.
#   On Slackware, parses `/etc/slackware-version`.
#   On Amazon Linux, returns the lsbdistrelease fact's value.
#   On Mageia, parses `/etc/mageia-release` for the release version.
#   On all remaining systems, returns the kernelrelease fact's value.
#
#   For the major version, uses the value of the full release string to determine the major
#   release version.
#   In RedHat osfamily derivatives and Debian, splits down the release string for a decimal point
#   and uses the first non-decimal character.
#   In Solaris, uses the first non-decimal character of the release string.
#   In Ubuntu, uses the characters before and after the first decimal point, as in '14.04'.
#   In Windows, uses the full release string in the case of server releases, such as '2012 R2',
#   and uses the first non-decimal character in the cases of releases such as '8.1'.
#
#   For the minor version, attempts to split the full release version string and return
#   the value of the character after the first decimal.
#
#   For the lsb entries, uses the `lsb_release` system command.
#
# Caveats:
#   The family entry is completely reliant on the name key, and no heuristics are used.
#
#   The major and minor release sub-facts of the release entry are not currenty
#   supported on all platforms.
#
#   The lsb entries only work on Linux (and the kfreebsd derivative) systems. Requires
#   the `lsb_release` program, which may not be installed by default. It is only as 
#   accurate as the output of `lsb_release`.
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
