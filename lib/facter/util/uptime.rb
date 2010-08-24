require 'time'

# A module to gather uptime facts
#
module Facter::Util::Uptime
    def self.get_uptime_seconds_unix
        uptime_proc_uptime or uptime_sysctl or uptime_who_dash_b
    end

    def self.get_uptime_seconds_win
      require 'win32ole'
      wmi = WIN32OLE.connect("winmgmts://")
      query = wmi.ExecQuery("select * from Win32_OperatingSystem")
      last_boot = ""
      query.each { |x| last_boot = x.LastBootupTime}
      self.compute_uptime(Time.parse(last_boot.split('.').first)) 
    end

    private

    def self.uptime_proc_uptime
        if output = Facter::Util::Resolution.exec("/bin/cat #{uptime_file} 2>/dev/null")
            output.chomp.split(" ").first.to_i
        end
    end

    def self.uptime_sysctl
        if output = Facter::Util::Resolution.exec("#{uptime_sysctl_cmd} 2>/dev/null")
            compute_uptime(Time.at(output.unpack('L').first))
        end
    end

    def self.uptime_who_dash_b
        if output = Facter::Util::Resolution.exec("#{uptime_who_cmd} 2>/dev/null")
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
