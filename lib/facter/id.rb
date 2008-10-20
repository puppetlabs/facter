Facter.add(:id) do
    confine :operatingsystem => %w{Solaris Linux Fedora RedHat CentOS SuSE SLES Debian Ubuntu Gentoo AIX}
    setcode "whoami"
end
