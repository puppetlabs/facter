# Fact: operatingsystemmajrelease
#
# Purpose: Returns the major release of the operating system.
#
# Resolution:
#   Splits down the operatingsystemrelease fact at decimal point for
#   osfamily RedHat derivatives and Debian.
#   Uses operatingsystemrelease to the first non decimal character for
#   operatingsystem Solaris
#
# This should be the same as lsbmajdistrelease, but on minimal systems there
# are too many dependencies to use LSB
#
# List of operatingsystems at time of writing:
#"Alpine" "Amazon" "Archlinux" "Ascendos" "Bluewhite64" "CentOS" "CloudLinux" 
#"Debian" "Fedora" "Gentoo" "Mandrake" "Mandriva" "MeeGo" "OEL" "OpenSuSE" 
#"OracleLinux" "OVS" "PSBM" "RedHat" "Scientific" "Slackware" "Slamd64" "SLC"
#"SLED" "SLES" "SuSE" "Ubuntu" "VMWareESX"

Facter.add(:operatingsystemmajrelease) do
  confine :operatingsystem => [
    :Amazon,
    :CentOS,
    :CloudLinux,
    :Debian,
    :Fedora,
    :OEL,
    :OracleLinux,
    :OVS,
    :RedHat,
    :Scientific,
    :SLC,
    :CumulusLinux
  ]
  setcode do
    Facter.value('operatingsystemrelease').split('.').first
  end
end

Facter.add(:operatingsystemmajrelease) do
  confine :operatingsystem => :solaris
  setcode do
    if match = Facter.value(:operatingsystemrelease).match(/^(\d+)/)
      match.captures[0]
    end
  end
end
