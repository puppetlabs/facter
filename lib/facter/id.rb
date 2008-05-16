        Facter.add(:id) do
            confine :operatingsystem => %w{Solaris Linux Fedora RedHat CentOS SuSE Debian Gentoo}
            setcode "whoami"
        end
