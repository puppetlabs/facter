Facter.add(:operatingsystemrelease) do
    confine :operatingsystem => :fedora
    setcode do
        File::open("/etc/fedora-release", "r") do |f|
            line = f.readline.chomp
            if line =~ /\(Rawhide\)$/
                "Rawhide"
            elsif line =~ /release (\d+)/
                $1
            end
        end
    end
end

Facter.add(:operatingsystemrelease) do
    confine :operatingsystem => %w{RedHat}
    setcode do
        File::open("/etc/redhat-release", "r") do |f|
            line = f.readline.chomp
            if line =~ /\(Rawhide\)$/
                "Rawhide"
            elsif line =~ /release (\d+)/
                $1
            end
        end
    end
end

Facter.add(:operatingsystemrelease) do
    confine :operatingsystem => :oel
    setcode do
        File::open("/etc/enterprise-release", "r") do |f|
            line = f.readline.chomp
            if line =~ /release (\d+)/
                $1
            end
        end
    end
end

Facter.add(:operatingsystemrelease) do
    confine :operatingsystem => :ovs
    setcode do
        File::open("/etc/ovs-release", "r") do |f|
            line = f.readline.chomp
            if line =~ /release (\d+)/
                $1
            end
        end
    end
end

Facter.add(:operatingsystemrelease) do
    confine :operatingsystem => %w{CentOS}
    setcode do
        centos_release = Facter::Util::Resolution.exec("sed -r -e 's/CentOS release //' -e 's/ \\((Branch|Final)\\)//' /etc/redhat-release")
        if centos_release =~ /^5/
            release = Facter::Util::Resolution.exec('rpm -q --qf \'%{VERSION}.%{RELEASE}\' centos-release | cut -d. -f1,2')
        else
            release = centos_release
        end
    end
end

Facter.add(:operatingsystemrelease) do
    confine :operatingsystem => %w{Debian}
    setcode do
        release = Facter::Util::Resolution.exec('cat /etc/debian_version')
    end
end

Facter.add(:operatingsystemrelease) do
    confine :operatingsystem => %w{Ubuntu}
    setcode do
        release = Facter::Util::Resolution.exec('cat /etc/issue')
        if release =~ /Ubuntu (\d+.\d+)/
            $1
        end
    end
end

Facter.add(:operatingsystemrelease) do
    confine :operatingsystem => %w{SLES SLED OpenSuSE}
    setcode do
        releasefile = Facter::Util::Resolution.exec('cat /etc/SuSE-release')
        if releasefile =~ /^VERSION\s*=\s*(\d+)/
            releasemajor = $1
            if releasefile =~ /^PATCHLEVEL\s*=\s*(\d+)/
                releaseminor = $1
            elsif releasefile =~ /^VERSION\s=.*.(\d+)/
                releaseminor = $1
            else
                releaseminor = "0"
            end
            releasemajor + "." + releaseminor
        else
            "unknown"
        end
    end
end

Facter.add(:operatingsystemrelease) do
    setcode do Facter[:kernelrelease].value end
end
