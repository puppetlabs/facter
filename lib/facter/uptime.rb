require 'facter/util/uptime'

Facter.add(:uptime) do
    confine :operatingsystem => %w{Solaris Linux Fedora RedHat CentOS SuSE SLES Debian Ubuntu Gentoo AIX}
    setcode do
        Facter::Util::Uptime.get_uptime_simple
    end
end

if FileTest.exists?("/proc/uptime")
    uptime = Facter::Util::Uptime.get_uptime

    %w{days hours seconds}.each do |label|
        Facter.add("uptime_" + label) do
            setcode do
                Facter::Util::Uptime.get_uptime_period(uptime, label)
            end 
        end 
    end 
end
