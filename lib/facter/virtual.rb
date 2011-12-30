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
#   Much of the logic here is obscured behind util/virtual.rb, which rather
#   than document here, which would encourage drift, just refer to it.
#   The Xen tests in here rely on /sys and /proc, and check for the presence and
#   contents of files in there.
#   If after all the other tests, it's still seen as physical, then it tries to
#   parse the output of the "lspci", "dmidecode" and "prtdiag" and parses them
#   for obvious signs of being under VMWare, Parallels or VirtualBox.
#   Finally it checks for the existence of vmware-vmx, which would hint it's
#   VMWare.
#
# Caveats:
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
      result = "virtualbox" if output["spdisplays_vendor-id"] =~ /0x80ee/
    end
    result
  end
end


Facter.add("virtual") do
  confine :kernel => %w{Linux FreeBSD OpenBSD SunOS HP-UX GNU/kFreeBSD}

  result = "physical"

  setcode do

    if Facter.value(:kernel) == "SunOS" and Facter::Util::Virtual.zone?
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
      if FileTest.exists?("/proc/xen/xsd_kva")
        result = "xen0"
      elsif FileTest.exists?("/proc/xen/capabilities")
        result = "xenu"
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
          # ---   00:0f.0 VGA compatible controller: VMware Inc [VMware SVGA II] PCI Display Adapter
          result = "vmware" if p =~ /VM[wW]are/
          # --- look for virtualbox video card to determine if it is virtual => virtualbox.
          # ---   00:02.0 VGA compatible controller: InnoTek Systemberatung GmbH VirtualBox Graphics Adapter
          result = "virtualbox" if p =~ /VirtualBox/
          # --- look for pci vendor id used by Parallels video card
          # ---   01:00.0 VGA compatible controller: Unknown device 1ab8:4005
          result = "parallels" if p =~ /1ab8:|[Pp]arallels/
          # --- look for pci vendor id used by Xen HVM device
          # ---   00:03.0 Unassigned class [ff80]: XenSource, Inc. Xen Platform Device (rev 01)
          result = "xenhvm" if p =~ /XenSource/
          # --- look for Hyper-V video card
          # ---   00:08.0 VGA compatible controller: Microsoft Corporation Hyper-V virtual VGA
          result = "hyperv" if p =~ /Microsoft Corporation Hyper-V/
        end
      else
        output = Facter::Util::Resolution.exec('dmidecode')
        if not output.nil?
          output.each_line do |pd|
            result = "parallels" if pd =~ /Parallels/
            result = "vmware" if pd =~ /VMware/
            result = "virtualbox" if pd =~ /VirtualBox/
            result = "xenhvm" if pd =~ /HVM domU/
            result = "hyperv" if pd =~ /Product Name: Virtual Machine/
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
              result = "xenhvm" if pd =~ /HVM domU/
            end
          end
        elsif Facter.value(:kernel) == 'OpenBSD'
          output = Facter::Util::Resolution.exec('sysctl -n hw.product 2>/dev/null')
          if not output.nil?
            output.each_line do |pd|
              result = "parallels" if pd =~ /Parallels/
              result = "vmware" if pd =~ /VMware/
              result = "virtualbox" if pd =~ /VirtualBox/
              result = "xenhvm" if pd =~ /HVM domU/
            end
          end
        end
      end

      if output = Facter::Util::Resolution.exec("vmware -v")
        result = output.sub(/(\S+)\s+(\S+).*/) { | text | "#{$1}_#{$2}"}.downcase
      end
    end

    result
  end
end

# Fact: is_virtual
#
# Purpose: returning true or false for if a machine is virtualised or not.
#
# Resolution: Hypervisors and the like may be detected as a virtual type, but
# are not actual virtual machines, or should not be treated as such. This
# determines if the host is actually virtualized.
#
# Caveats:
#

Facter.add("is_virtual") do
  confine :kernel => %w{Linux FreeBSD OpenBSD SunOS HP-UX Darwin GNU/kFreeBSD}

  setcode do
    physical_types = %w{physical xen0 vmware_server vmware_workstation openvzhn}

    if physical_types.include? Facter.value(:virtual)
      "false"
    else
      "true"
    end
  end
end
