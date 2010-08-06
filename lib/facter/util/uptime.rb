require 'time'

# A module to gather uptime facts
#
module Facter::Util::Uptime
    def self.get_uptime_seconds_unix
        uptime_proc_uptime or uptime_sysctl or uptime_who_dash_b
    end

    def self.get_uptime_seconds_win
        require 'Win32API'
        getTickCount = Win32API.new("kernel32", "GetTickCount", nil, 'L')
        compute_uptime(Time.at(getTickCount.call() / 1000.0))
    end

    private

    def self.uptime_proc_uptime
        if output = `/bin/cat #{uptime_file} 2>/dev/null` and $?.success?
            output.chomp.split(" ").first.to_i
        end
    end

    def self.uptime_sysctl
        if output = `#{uptime_sysctl_cmd} 2>/dev/null` and $?.success?
            compute_uptime(Time.at(output.unpack('L').first))
        end
    end

    def self.uptime_who_dash_b
        if output = `#{uptime_who_cmd} 2>/dev/null` and $?.success?
            compute_uptime(Time.parse(output))
        end
    end

    def self.compute_uptime(time)
        (Time.now - time).to_i
    end

    def self.uptime_file
        "/proc/uptime"
    end

    def self.uptime_sysctl_cmd
        'sysctl -b kern.boottime'
    end

    def self.uptime_who_cmd
        'who -b'
    end
end
