Facter.add(:uniqueid) do
    setcode 'hostid'
    confine :operatingsystem => %w{Solaris Linux Fedora RedHat CentOS Scientific SuSE SLES Debian Ubuntu Gentoo AIX OEL OVS GNU/kFreeBSD}
end
