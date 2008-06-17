# lsbmajdistrelease.rb
#
require 'facter'

Facter.add("lsbmajdistrelease") do
    confine :operatingsystem => %w{Solaris Linux Fedora RedHat CentOS SuSE Debian Gentoo}
    setcode do
        if /(\d*)\./i =~ Facter.value(:lsbdistrelease)
            result=$1
        else
            result=Facter.value(:lsbdistrelease)
        end
        result
    end
end
