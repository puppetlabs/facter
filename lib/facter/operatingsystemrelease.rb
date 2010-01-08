Facter.add(:operatingsystemrelease) do
    confine :operatingsystem => %w{CentOS Fedora oel ovs RedHat}
    setcode do
        case Facter.value(:operatingsystem)
        when "CentOS", "RedHat"
            releasefile = "/etc/redhat-release"
        when "Fedora"
            releasefile = "/etc/fedora-release"
        when "OEL"
            releasefile = "/etc/enterprise-release"
        when "OVS"
            releasefile = "/etc/ovs-release"
        end
        File::open(releasefile, "r") do |f|
            line = f.readline.chomp
            if line =~ /\(Rawhide\)$/
                "Rawhide"
            elsif line =~ /release (\d[\d.]*)/
                $1
            end
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
    confine :operatingsystem => %w{Slackware}
    setcode do
        release = Facter::Util::Resolution.exec('cat /etc/slackware-version')
        if release =~ /Slackware ([0-9.]+)/
            $1
        end
    end
end

Facter.add(:operatingsystemrelease) do
    setcode do Facter[:kernelrelease].value end
end
