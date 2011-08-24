# Fact: virtual
#
# Purpose: Determine if the system's hardware is real or virtualised.
#
# Resolution:
#   Assumes physical unless proven otherwise.
#
#   On Darwin, use the macosx util module to acquire the SPDisplaysDataType,
#   from that parse it to see if it's VMWare or Parallels pretending to be the
#   display.
#
#   On Linux, BSD, Solaris and HPUX:
#     Much of the logic here is obscured behind util/virtual.rb, which rather
#     than document here, which would encourage drift, just refer to it.
#   The Xen tests in here rely on /sys and /proc, and check for the presence and
#   contents of files in there.
#   If after all the other tests, it's still seen as physical, then it tries to
#   parse the output of the "lspci", "dmidecode" and "prtdiag" and parses them
#   for obvious signs of being under VMWare or Parallels.
#   Finally it checks for the existence of vmware-vmx, which would hint it's
#   VMWare.
#
# Caveats:
#   Virtualbox detection isn't implemented. 
#   Many checks rely purely on existence of files.
#

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

        if Facter.value(:operatingsystem) == "Solaris" and Facter::Util::Virtual.zone?
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
                    # --- look for virtualbox video card to determine if it is virtual => virtualbox.
                    # ---     00:02.0 VGA compatible controller: InnoTek Systemberatung GmbH VirtualBox Graphics Adapter
                    result = "virtualbox" if p =~ /VirtualBox/
                    # --- look for pci vendor id used by Parallels video card
                    # ---   01:00.0 VGA compatible controller: Unknown device 1ab8:4005
                    result = "parallels" if p =~ /1ab8:|[Pp]arallels/
                    # Virtual box deploys a VGA compatble controller
                    # 00:02.0 VGA compatible controller: InnoTek Systemberatung GmbH VirtualBox Graphics Adapter
                    # And a system device 
                    # 00:04.0 System peripheral: InnoTek Systemberatung GmbH VirtualBox Guest Service
                    # Assuming that oracle will push their name here as well
                    result = "virtualbox" if p =~ /VirtualBox/
                end
            else
                output = Facter::Util::Resolution.exec('dmidecode')
                if not output.nil?
                    output.each_line do |pd|
                        result = "parallels" if pd =~ /Parallels/
                        result = "vmware" if pd =~ /VMware/
                        result = "virtualbox" if pd =~ /VirtualBox/
                    end
                elsif Facter.value(:kernel) == 'SunOS'
                    res = Facter::Util::Resolution.new('prtdiag')
                    res.timeout = 6
                    res.setcode('prtdiag')
                    output = res.value
                    if not output.nil?
                        output.each_line do |pd|
                            result = "parallels" if pd =~ /Parallels/
                            result = "vmware" if pd =~ /VMware/
							result = "virtualbox" if pd =~ /VirtualBox/
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

# Fact: is_virtual
#
# Purpose: returning true or false for if a machine is virtualised or not.
#
# Resolution: The Xen domain 0 machine is virtualised to a degree, but is generally
# not viewed as being a virtual machine. This checks that the machine is not
# physical nor xen0, if that is the case, it is virtual.
#
# Caveats:
#

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
