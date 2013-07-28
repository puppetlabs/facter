require 'facter/util/posix'

module Facter::Util::Blockdevices

  module FreeBSD
    def self.device_vendor(device_name)
      vendor_and_model(device_name).first
    end

    def self.device_model(device_name)
      vendor_and_model(device_name).last
    end

    def self.device_size(device_name)
      if device_name =~ /acd|cd/
        "0"
      else
        cmd_out = Facter::Util::Resolution.exec("/usr/sbin/diskinfo -v #{device_name}")
        parse_diskinfo_size cmd_out
      end
    end

    def self.devices
      Facter::Util::POSIX.sysctl('kern.disks').split(' ').sort
    end

    private

    def self.vendor_and_model(device_name)
      devicestring = ""
      if device_name =~ /ada/
        cmd_out = Facter::Util::Resolution.exec("/sbin/camcontrol identify #{device_name}")
        devicestring = parse_camcontrol cmd_out
      elsif device_name =~ /ad/
        cmd_out = Facter::Util::Resolution.exec("/sbin/atacontrol cap #{device_name}")
        devicestring = parse_atacontrol cmd_out
      elsif device_name =~ /mfi/
        devicestring = "MFI Local Disk"
      else
        cmd_out = Facter::Util::Resolution.exec("/sbin/camcontrol inquiry #{device_name} -D")
        devicestring = parse_camcontrol cmd_out
      end

      devicestring.split(' ', 2)
    end

    def self.parse_camcontrol(output_str)
      if output_str =~ /\s<(.+?)>\s/m
        $1
      else
        raise "parse_camcontrol failed. output string:\n#{output_str}"
      end
    end

    def self.parse_diskinfo_size(output_str)
      entries = output_str.split(/\n/).map{|l| l.split(/\s+\#\s+/)}
      match = entries.find{|(_, label)| label =~ /mediasize in bytes/ }
      if match
        match.first.strip
      else
        raise "parsing diskinfo output failed. output:\n#{output_str}"
      end
    end

    def self.parse_atacontrol(output_str)
      entries = output_str.split(/\n/).map{|l| l.split(/\s{2,}/) }
      match = entries.find{|(label, _)| label =~ /device model/ }
      if match
        "ATA #{match.last.strip}"
      else
        raise "parsing atacontrol output failed. output:\n#{output_str}"
      end
    end

  end
end
