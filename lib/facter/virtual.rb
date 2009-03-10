Facter.add("virtual") do
    confine :kernel => %w{Linux FreeBSD OpenBSD SunOS}

    result = "physical"

    setcode do
    require 'thread'

        if FileTest.exists?("/proc/user_beancounters")
            # openvz. can be hardware node or virtual environment
            # read the init process' status file, it has laxer permissions
            # than /proc/user_beancounters (so this won't fail as non-root)
            txt = File.read("/proc/1/status")
            if txt =~ /^envID:[[:blank:]]+0$/mi
                result = "openvzhn"
            else
                result = "openvzve"
            end
        end

        Thread::exclusive do
            if FileTest.exists?("/proc/xen/capabilities") && FileTest.readable?("/proc/xen/capabilities")
                txt = File.read("/proc/xen/capabilities")
                    if txt =~ /control_d/i
                        result = "xen0"
                    else
                        result = "xenu"
                    end
             end
        end

        if result == "physical"
            output = Facter::Util::Resolution.exec('lspci')
            if not output.nil?
                output.each do |p|
                    # --- look for the vmware video card to determine if it is virtual => vmware.
                    # ---     00:0f.0 VGA compatible controller: VMware Inc [VMware SVGA II] PCI Display Adapter
                    result = "vmware" if p =~ /VM[wW]are/
                end
            else
                output = Facter::Util::Resolution.exec('dmidecode')
                if not output.nil?
                    output.each do |pd|
                        result = "vmware" if pd =~ /VMware|Parallels/
                    end
                else
                    output = Facter::Util::Resolution.exec('prtdiag')
                    if not output.nil?
                        output.each do |pd|
                            result = "vmware" if pd =~ /VMware|Parallels/
                        end
                    end
                end
            end
        end

        # VMware server 1.0.3 rpm places vmware-vmx in this place, other versions or platforms may not.
        if FileTest.exists?("/usr/lib/vmware/bin/vmware-vmx")
            result = "vmware_server"
        end

        output = Facter::Util::Resolution.exec('mount')
        if not output.nil?
            output.each do |p|
                result = "vserver" if p =~ /\/dev\/hdv1/
            end
        end

        if FileTest.directory?('/proc/virtual') && result=="physical"
            result = "vserver_host"
        end

        result
    end
end
  
Facter.add("is_virtual") do
    confine :kernel => %w{Linux FreeBSD OpenBSD SunOS}

    setcode do
        case Facter.value(:virtual)
        when "xenu", "openvzve", "vmware" 
            true
        else 
            false
        end
    end
end
