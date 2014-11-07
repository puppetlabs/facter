# Fact: operatingsystemmajrelease
#
# Purpose: Returns the major release of the operating system.
#
# Resolution:
#   Uses the release['major'] entry of the os structured fact, which itself
#   attempts to use its own release['full'] entry to determine the major release value.
#   In RedHat osfamily derivatives and Debian, splits down the release string for a decimal point
#   and uses the first non-decimal character.
#   In Solaris, uses the first non-decimal character of the release string.
#   In Ubuntu, uses the characters before and after the first decimal point, as in '14.04'.
#   In Windows, uses the full release string in the case of server releases, such as '2012 R2',
#   and uses the first non-decimal character in the cases of releases such as '8.1'.
#
#   This should be the same as lsbmajdistrelease, but on minimal systems there
#   are too many dependencies to use LSB
#
# List of operatingsystems at time of writing:
#   "Alpine" "Amazon" "Archlinux" "Ascendos" "Bluewhite64" "CentOS" "CloudLinux" 
#   "Debian" "Fedora" "Gentoo" "Mandrake" "Mandriva" "MeeGo" "OEL" "OpenSuSE" 
#   "OracleLinux" "OVS" "PSBM" "RedHat" "Scientific" "Slackware" "Slamd64" "SLC"
#   "SLED" "SLES" "Solaris" "SuSE" "Ubuntu" "VMWareESX"
#

Facter.add(:operatingsystemmajrelease) do
  confine do
    !Facter.value("os")["release"]["major"].nil?
  end

  setcode { Facter.value("os")["release"]["major"].to_s }
end
