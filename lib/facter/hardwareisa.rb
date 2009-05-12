Facter.add(:hardwareisa) do
    setcode 'uname -p', '/bin/sh'
    confine :operatingsystem => %w{Solaris Linux Fedora RedHat CentOS SuSE SLES Debian Ubuntu Gentoo FreeBSD OpenBSD NetBSD OEL OVS}
end
