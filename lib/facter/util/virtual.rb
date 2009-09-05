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
end
