module Facter::Util::Virtual
  def self.openvz?
    FileTest.directory?("/proc/vz") and not self.openvz_cloudlinux?
  end

  # So one can either have #6728 work on OpenVZ or Cloudlinux. Whoo.
  def self.openvz_type
    return false unless self.openvz?
    return false unless FileTest.exists?( '/proc/self/status' )

    envid = Facter::Util::Resolution.exec( 'grep "envID" /proc/self/status' )
    if envid =~ /^envID:\s+0$/i
    return 'openvzhn'
    elsif envid =~ /^envID:\s+(\d+)$/i
    return 'openvzve'
    end
  end

  # Cloudlinux uses OpenVZ to a degree, but always has an empty /proc/vz/ and
  # has /proc/lve/list present
  def self.openvz_cloudlinux?
    FileTest.file?("/proc/lve/list") or Dir.glob('/proc/vz/*').empty?
  end

  def self.zone?
    return true if FileTest.directory?("/.SUNWnative")
    z = Facter::Util::Resolution.exec("/sbin/zonename")
    return false unless z
    return z.chomp != 'global'
  end

  def self.vserver?
    return false unless FileTest.exists?("/proc/self/status")
    txt = File.read("/proc/self/status")
    return true if txt =~ /^(s_context|VxID):[[:blank:]]*[0-9]/
    return false
  end

  def self.vserver_type
    if self.vserver?
      if FileTest.exists?("/proc/virtual")
        "vserver_host"
      else
        "vserver"
      end
    end
  end

  def self.xen?
    ["/proc/sys/xen", "/sys/bus/xen", "/proc/xen" ].detect do |f|
      FileTest.exists?(f)
    end
  end

  def self.kvm?
     txt = if FileTest.exists?("/proc/cpuinfo")
       File.read("/proc/cpuinfo")
     elsif ["FreeBSD", "OpenBSD"].include? Facter.value(:kernel)
       Facter::Util::Resolution.exec("/sbin/sysctl -n hw.model")
     end
     (txt =~ /QEMU Virtual CPU/) ? true : false
  end

  def self.kvm_type
    # TODO Tell the difference between kvm and qemu
    # Can't work out a way to do this at the moment that doesn't
    # require a special binary
    "kvm"
  end

  def self.jail?
    path = case Facter.value(:kernel)
      when "FreeBSD" then "/sbin"
      when "GNU/kFreeBSD" then "/bin"
    end
    Facter::Util::Resolution.exec("#{path}/sysctl -n security.jail.jailed") == "1"
  end

  def self.hpvm?
    Facter::Util::Resolution.exec("/usr/bin/getconf MACHINE_MODEL").chomp =~ /Virtual Machine/
  end

   def self.zlinux?
    "zlinux"
   end
end
