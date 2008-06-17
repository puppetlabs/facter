Facter.add(:hardwareisa) do
    setcode 'uname -p', '/bin/sh'
    confine :operatingsystem => %w{Solaris Linux Fedora RedHat CentOS SuSE Debian Gentoo FreeBSD OpenBSD NetBSD}
end
