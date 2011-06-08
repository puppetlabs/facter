# Fact: osfamily
#
# Purpose: Returns the operating system
#
# Resolution:
#   Maps operating systems to operating system families, such as linux
#   distribution derivatives. Adds mappings from specific operating systems
#   to kernels in the case that it is relevant.
#
# Caveats:
#   This fact is completely reliant on the operatingsystem fact, and no
#   heuristics are used
#

Facter.add(:osfamily) do

  setcode do
    case Facter.value(:operatingsystem)
    when "RedHat", "Fedora", "CentOS", "Scientific", "SLC", "CloudLinux", "OracleLinux", "OVS", "OEL"
      "RedHat"
    when "Ubuntu", "Debian"
      "Debian"
    when "SLES", "SLED", "OpenSuSE", "SuSE"
      "Suse"
    when "Solaris"
      "Solaris"
    else
      Facter.value("kernel")
    end
  end
end
