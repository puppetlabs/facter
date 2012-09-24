require 'time'

# A module to gather uptime facts
#
module Facter::Util::Uptime
  def self.get_uptime_seconds_unix
    uptime_proc_uptime or uptime_sysctl or uptime_uptime
  end

  def self.get_uptime_seconds_win
    require 'facter/util/wmi'

    last_boot = ""
    Facter::Util::WMI.execquery("select * from Win32_OperatingSystem").each do |x|
      last_boot = x.LastBootupTime
    end
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
      compute_uptime(Time.at(output.match(/\d+/)[0].to_i))
    end
  end

  def self.uptime_uptime
    if output = Facter::Util::Resolution.exec("#{uptime_uptime_cmd} 2>/dev/null")
      up=0
      if output =~ /(\d+) day(?:s|\(s\))?,\s+(\d+):(\d+)/
        # Regexp handles Solaris, AIX, HP-UX, and Tru64.
        # 'day(?:s|\(s\))?' says maybe 'day', 'days',
        #   or 'day(s)', and don't set $2.
        up=86400*$1.to_i + 3600*$2.to_i + 60*$3.to_i
      elsif output =~ /(\d+) day(?:s|\(s\))?,\s+(\d+) hr(?:s|\(s\))?,/
        up=86400*$1.to_i + 3600*$2.to_i
      elsif output =~ /(\d+) day(?:s|\(s\))?,\s+(\d+) min(?:s|\(s\))?,/
        up=86400*$1.to_i + 60*$2.to_i
      elsif output =~ /(\d+) day(?:s|\(s\))?,/
        up=86400*$1.to_i
      elsif output =~ /up\s+(\d+):(\d+),/
        # must anchor to 'up' to avoid matching time of day
        # at beginning of line.
        up=3600*$1.to_i + 60*$2.to_i
      elsif output =~ /(\d+) hr(?:s|\(s\))?,/
        up=3600*$1.to_i
      elsif output =~ /(\d+) min(?:s|\(s\))?,/
        up=60*$1.to_i
      end
      up
    end
  end

  def self.compute_uptime(time)
    (Time.now - time).to_i
  end

  def self.uptime_file
    "/proc/uptime"
  end

  def self.uptime_sysctl_cmd
    'sysctl -n kern.boottime'
  end

  def self.uptime_uptime_cmd
    "/usr/bin/uptime"
  end
end
