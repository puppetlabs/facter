module Facter::Util::Virtual
    def self.openvz?
        FileTest.exists?("/proc/vz/veinfo")
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
        return true if txt =~ /^(s_context|VxID):[[:blank:]]*[1-9]/
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
       if FileTest.exists?("/proc/cpuinfo")
           txt = File.read("/proc/cpuinfo")
           return true if txt =~ /QEMU Virtual CPU/
       end
       return false
    end

    def self.kvm_type
      # TODO Tell the difference between kvm and qemu
      # Can't work out a way to do this at the moment that doesn't
      # require a special binary
      "kvm"
    end


end
