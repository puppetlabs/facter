# A module to gather uptime facts
#
module Facter::Util::Uptime
    def self.get_uptime_simple
        time = Facter::Util::Resolution.exec('uptime')
        if time =~ /up\s*(\d+\s\w+)/
            $1
        elsif time =~ /up\s*(\d+:\d+)/
            $1 + " hours"
        else
            "unknown"
        end
    end

    def self.get_uptime
        r = IO.popen("/bin/cat /proc/uptime")
        uptime, idletime = r.readline.split(" ")        
        r.close
        uptime_seconds = uptime.to_i
    end

    def self.get_uptime_period(seconds, label)
        case label
        when 'days'
            value = seconds / 86400
        when 'hours'
            value = seconds / 3600
        when 'seconds'
            seconds
        end     
    end
end   
