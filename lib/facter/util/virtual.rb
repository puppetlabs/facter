module Facter::Util::Virtual
    def self.openvz?
        FileTest.directory?("/proc/vz") and FileTest.exists?( '/proc/vz/veinfo' )
    end

    def self.openvz_type
        return nil unless self.openvz?
        if FileTest.exists?("/proc/vz/version")
            result = "openvzhn"
        else
            result = "openvzve"
        end
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
       elsif Facter.value(:kernel)=="FreeBSD"
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
