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
      centosrelease = Facter::Util::Resolution.exec('cat /etc/redhat-release | sed -e \'s/CentOS release//g\' -e \'s/(Final)//g\'')
        if centosrelease =~ /^5^/
          release = Facter::Util::Resolution.exec('rpm -q --qf \'%{VERSION}.%{RELEASE}\' centos-release | cut -d. -f1,2')
        else
          release = Facter::Util::Resolution.exec('cat /etc/redhat-release | sed -e \'s/CentOS release//g\' -e \'s/(Final)//g\'')
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
