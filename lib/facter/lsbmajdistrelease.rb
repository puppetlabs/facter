# lsbmajdistrelease.rb
#
require 'facter'

Facter.add("lsbmajdistrelease") do
    confine :operatingsystem => %w{Linux Fedora RedHat CentOS SuSE SLES Debian Ubuntu Gentoo OEL OVS GNU/kFreeBSD}
    setcode do
        if /(\d*)\./i =~ Facter.value(:lsbdistrelease)
            result=$1
        else
            result=Facter.value(:lsbdistrelease)
        end
        result
    end
end
