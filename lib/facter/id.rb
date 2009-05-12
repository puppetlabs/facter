Facter.add(:id) do
    confine :operatingsystem => %w{Linux Fedora RedHat CentOS SuSE SLES Debian Ubuntu Gentoo AIX OEL OVS}
    setcode "whoami"
end

Facter.add(:id) do
    confine :operatingsystem => %w{Solaris}
    setcode do
        if %x{id} =~ /^uid=\d+\((\S+)\)/
            $1
        else
            nil
        end
    end
end
