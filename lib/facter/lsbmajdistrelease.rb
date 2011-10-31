# Fact: lsbmajdistrelease
#
# Purpose: Returns the major version of the operation system version as gleaned
# from the lsbdistrelease fact.
#
# Resolution:
#   Parses the lsbdistrelease fact for numbers followed by a period and
#   returns those, or just the lsbdistrelease fact if none were found.
#
# Caveats:
#

# lsbmajdistrelease.rb
#
require 'facter'

Facter.add("lsbmajdistrelease") do
  confine :operatingsystem => %w{Linux Fedora RedHat CentOS Scientific PSBM SLC Ascendos SuSE SLES Debian Ubuntu Gentoo OEL OracleLinux OVS GNU/kFreeBSD}
  setcode do
    if /(\d*)\./i =~ Facter.value(:lsbdistrelease)
      result=$1
    else
      result=Facter.value(:lsbdistrelease)
    end
    result
  end
end
