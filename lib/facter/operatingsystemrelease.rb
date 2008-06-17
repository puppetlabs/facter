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
    confine :operatingsystem => %w{CentOS}
    setcode do
        release = Facter::Util::Resolution.exec('rpm -q centos-release')
            if release =~ /release-(\d+)/
                $1
            end
    end
end

Facter.add(:operatingsystemrelease) do
    confine :operatingsystem => %w{Debian}
    setcode do
        release = Facter::Util::Resolution.exec('cat /proc/version')
            if release =~ /\(Debian (\d+.\d+).\d+-\d+\)/
                $1
            end
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
    setcode do Facter[:kernelrelease].value end
end
