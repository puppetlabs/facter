require 'time'

# A module to gather uptime facts
#
module Facter::Util::Uptime
  def self.get_uptime_seconds_unix
    uptime_proc_uptime or uptime_sysctl or uptime_executable
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
    output = Facter::Core::Execution.execute("/bin/cat #{uptime_file} 2>/dev/null")

    if not output.empty?
      output.chomp.split(" ").first.to_i
    end
  end

  def self.uptime_sysctl
    require 'facter/util/posix'
    output = Facter::Util::POSIX.sysctl(uptime_sysctl_variable)
    if output
      compute_uptime(Time.at(output.match(/\d+/)[0].to_i))
    end
  end

  def self.uptime_executable
    output = Facter::Core::Execution.execute("#{uptime_executable_cmd} 2>/dev/null", :on_fail => nil)

    if output
      up=0
      if output =~ /(\d+) day(?:s|\(s\))?,?\s+(\d+):-?(\d+)/
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
      elsif output =~ /up\s+(\d+):-?(\d+),/
        # must anchor to 'up' to avoid matching time of day
        # at beginning of line. Certain versions of uptime on
        # Solaris may insert a '-' into the minutes field.
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

  def self.uptime_sysctl_variable
    'kern.boottime'
  end

  def self.uptime_executable_cmd
    "uptime"
  end
end
