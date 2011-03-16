require 'facter/util/virtual'

Facter.add("virtual") do
    confine :kernel => "Darwin"

    setcode do
        require 'facter/util/macosx'
        result = "physical"
        output = Facter::Util::Macosx.profiler_data("SPDisplaysDataType")
        if output.is_a?(Hash)
            result = "parallels" if output["spdisplays_vendor-id"] =~ /0x1ab8/
            result = "parallels" if output["spdisplays_vendor"] =~ /[Pp]arallels/
            result = "vmware" if output["spdisplays_vendor-id"] =~ /0x15ad/
            result = "vmware" if output["spdisplays_vendor"] =~ /VM[wW]are/
        end
        result
    end
end


Facter.add("virtual") do
    confine :kernel => %w{Linux FreeBSD OpenBSD SunOS HP-UX GNU/kFreeBSD}

    result = "physical"

    setcode do

        if Facter::Util::Virtual.zone? and Facter.value(:operatingsystem) == "Solaris"
            result = "zone"
        end

        if Facter.value(:kernel)=="HP-UX"
            result = "hpvm" if Facter::Util::Virtual.hpvm?
        end

        if Facter.value(:architecture)=="s390x"
            result = "zlinux" if Facter::Util::Virtual.zlinux?
        end

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
                txt = Facter::Util::Resolution.exec("cat /proc/xen/capabilities")
                if txt =~ /control_d/i
                    result = "xen0"
                end
            end
        end

        if Facter::Util::Virtual.kvm?
            result = Facter::Util::Virtual.kvm_type()
        end

        if ["FreeBSD", "GNU/kFreeBSD"].include? Facter.value(:kernel)
            result = "jail" if Facter::Util::Virtual.jail?
        end

        if result == "physical"
            output = Facter::Util::Resolution.exec('lspci')
            if not output.nil?
                output.each_line do |p|
                    # --- look for the vmware video card to determine if it is virtual => vmware.
                    # ---     00:0f.0 VGA compatible controller: VMware Inc [VMware SVGA II] PCI Display Adapter
                    result = "vmware" if p =~ /VM[wW]are/
                    # --- look for pci vendor id used by Parallels video card
                    # ---   01:00.0 VGA compatible controller: Unknown device 1ab8:4005
                    result = "parallels" if p =~ /1ab8:|[Pp]arallels/
                end
            else
                output = Facter::Util::Resolution.exec('dmidecode')
                if not output.nil?
                    output.each_line do |pd|
                        result = "parallels" if pd =~ /Parallels/
                        result = "vmware" if pd =~ /VMware/
                    end
                else
                    output = Facter::Util::Resolution.exec('prtdiag')
                    if not output.nil?
                        output.each_line do |pd|
                            result = "parallels" if pd =~ /Parallels/
                            result = "vmware" if pd =~ /VMware/
                        end
                    end
                end
            end
            
            if FileTest.exists?("/usr/lib/vmware/bin/vmware-vmx")
                result = "vmware_server"
            end
        end

        result
    end
end

Facter.add("is_virtual") do
    confine :kernel => %w{Linux FreeBSD OpenBSD SunOS HP-UX Darwin GNU/kFreeBSD}

    setcode do
        if Facter.value(:virtual) != "physical" && Facter.value(:virtual) != "xen0"
            "true"
        else
            "false"
        end
    end
end
