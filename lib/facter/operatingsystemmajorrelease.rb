# Fact: operatingsystemmajorrelease
#
# Purpose: Returns the major release of the operating system.
#
# Resolution: splits down the operatingsystemrelease fact at decimal point for 
#  osfamily RedHat derivatives, also Debian. 
#
# Caveats: The name of the fact is too long IMHO. 
# This should be the same as lsbmajdistrelease, but on minimal systems there
# are too many dependencies to use LSB
# we should probably use lsbmajdistrelease if available

Facter.add(:operatingsystemmajorrelease) do
  confine :osfamily => :RedHat
  setcode do
    Facter.value('operatingsystemrelease').split('.').first
  end
end

Facter.add(:operatingsystemrelease) do
  confine :operatingsystem => "Debian"
  setcode do
    Facter.value('operatingsystemrelease').split('.').first
  end
end
