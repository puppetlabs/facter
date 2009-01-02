Facter.add("virtual") do
    confine :kernel => %w{Linux FreeBSD OpenBSD SunOS}

    result = "physical"

    setcode do
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

        if FileTest.exists?("/proc/xen/capabilities") && FileTest.readable?("/proc/xen/capabilities")
            txt = File.read("/proc/xen/capabilities")
            if txt =~ /control_d/i
                result = "xen0"
            else
                result = "xenu"
            end
        end

        if result == "physical"
            path = %x{which lspci 2> /dev/null}.chomp
            if path !~ /no lspci/
                output = %x{#{path}}
                output.each do |p|
                    # --- look for the vmware video card to determine if it is virtual => vmware.
                    # ---     00:0f.0 VGA compatible controller: VMware Inc [VMware SVGA II] PCI Display Adapter
                    result = "vmware" if p =~ /VM[wW]are/
                end
            else
                path = %x{which dmidecode 2> /dev/null}.chomp
                if path !~ /no dmidecode/
                    output = %x{#{path}}
                    output.each do |pd|
                        result = "vmware" if pd =~ /VMware|Parallels/
                    end
                else
                    path = %x{which prtdiag 2> /dev/null}.chomp
                    if path !~ /no prtdiag/
                        output = %x{#{path}}
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

        mountexists = system "which mount > /dev/null 2>&1"
        if $?.exitstatus == 0
            output = %x{mount}
            output.each do |p|
                result = "vserver" if p =~ /\/dev\/hdv1/
            end
        end

        if FileTest.directory?('/proc/virtual')
            result = "vserver_host"
        end

        result
    end
end
