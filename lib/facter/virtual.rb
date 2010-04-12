require 'facter/util/virtual'

Facter.add("virtual") do
    confine :kernel => %w{Linux FreeBSD OpenBSD SunOS}

    result = "physical"

    setcode do

        result = "zone" if Facter::Util::Virtual.zone?

        if Facter::Util::Virtual.openvz?
            result = Facter::Util::Virtual.openvz_type()
        end

        if Facter::Util::Virtual.vserver?
            result = Facter::Util::Virtual.vserver_type()
        end

        if Facter::Util::Virtual.xen?
            # new Xen domains have this in dom0 not domu :(
            if FileTest.exists?("/proc/sys/xen/independent_wallclock")
                result = "xenu"
            end
            if FileTest.exists?("/sys/bus/xen")
                result = "xenu"
            end
        
            if FileTest.exists?("/proc/xen/capabilities")
                txt = File.read("/proc/xen/capabilities")
                if txt =~ /control_d/i
                    result = "xen0"
                end
            end
        end

        if Facter::Util::Virtual.kvm?
            result = Facter::Util::Virtual.kvm_type()
        end

        if result == "physical"
            output = Facter::Util::Resolution.exec('lspci')
            if not output.nil?
                output.each_line do |p|
                    # --- look for the vmware video card to determine if it is virtual => vmware.
                    # ---     00:0f.0 VGA compatible controller: VMware Inc [VMware SVGA II] PCI Display Adapter
                    result = "vmware" if p =~ /VM[wW]are/
                end
            else
                output = Facter::Util::Resolution.exec('dmidecode')
                if not output.nil?
                    output.each_line do |pd|
                        result = "vmware" if pd =~ /VMware|Parallels/
                    end
                else
                    output = Facter::Util::Resolution.exec('prtdiag')
                    if not output.nil?
                        output.each_line do |pd|
                            result = "vmware" if pd =~ /VMware|Parallels/
                        end
                    end
                end
            end
            # VMware server 1.0.3 rpm places vmware-vmx in this place, other versions or platforms may not.
            if FileTest.exists?("/usr/lib/vmware/bin/vmware-vmx")
                result = "vmware_server"
            end
        end

        result
    end
end
  
Facter.add("is_virtual") do
    confine :kernel => %w{Linux FreeBSD OpenBSD SunOS}

    setcode do
        case Facter.value(:virtual)
        when "xenu", "openvzve", "vmware", "kvm", "vserver"
            true
        else 
            false
        end
    end
end
