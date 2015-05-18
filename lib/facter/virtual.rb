# Fact: virtual
#
# Purpose: Determine if the system's hardware is real or virtualized.
#
# Resolution:
#   Assumes physical unless proven otherwise.
#
#   On Darwin, use the macosx util module to acquire the SPHardwareDataType
#   and SPEthernetDataType, from which it is possible to determine if the host is
#   a VMware, Parallels, or VirtualBox. This previously used SPDisplaysDataType,
#   which was not reliable if running headless, and also caused lagging issues
#   on actual Macs.
#
#   On Linux, BSD, Solaris and HPUX: Much of the logic here is obscured behind
#   `util/virtual.rb`, which you can consult directly for more detailed resolution
#   information.
#   The Xen tests in here rely on `/sys` and `/proc,` and check for the presence and
#   contents of files in there.
#   If after all the other tests it's still seen as physical, then it tries to
#   parse the output of the `lspci`, `dmidecode`, and `prtdiag` and parses them
#   for obvious signs of being under VMware, Parallels or VirtualBox.
#   Finally, it checks for the existence of `vmware-vmx`, which would hint that
#   it's VMware.
#
# Caveats:
#   Many checks rely purely on existence of files.
#

# Fact: is_virtual
#
# Purpose: Return `true` or `false` depending on whether a machine is virtualized or not.
#
# Resolution: Hypervisors and the like may be detected as a virtual type, but
#   are not actual virtual machines, or should not be treated as such. This
#   determines if the host is actually virtualized.
#
# Caveats:
#

require 'facter/util/virtual'

Facter.add("virtual") do
  confine :kernel => "Darwin"

  setcode do
    require 'facter/util/macosx'
    result = "physical"
    # use SPHardwareDataType for VMware and VirtualBox, since it is the most
    # reliable source.
    output = Facter::Util::Macosx.profiler_data("SPHardwareDataType")
    if output.is_a?(Hash)
      result = "vmware" if output["machine_model"] =~ /VMware/
      result = "virtualbox" if output["boot_rom_version"] =~ /VirtualBox/
    end
    # Parallels passes through almost all of the host's hardware info to the
    # virtual machine, so use a different field.
    output = Facter::Util::Macosx.profiler_data("SPEthernetDataType")
    if output.is_a?(Hash)
      result = "parallels" if output["spethernet_subsystem-vendor-id"] =~ /0x1ab8/
    end
    result
  end
end

Facter.add("virtual") do
  confine :kernel => ["FreeBSD", "GNU/kFreeBSD"]
  has_weight 10
  setcode do
    "jail" if Facter::Util::Virtual.jail?
  end
end

Facter.add("virtual") do
  confine :kernel => 'SunOS'
  has_weight 10
  self.timeout = 20

  setcode do
    next "zone" if Facter::Util::Virtual.zone?

    output = Facter::Core::Execution.exec('prtdiag 2>/dev/null')
    if output
      lines = output.split("\n")
      next "parallels"  if lines.any? {|l| l =~ /Parallels/ }
      next "vmware"     if lines.any? {|l| l =~ /VM[wW]are/ }
      next "virtualbox" if lines.any? {|l| l =~ /VirtualBox/ }
      next "xenhvm"     if lines.any? {|l| l =~ /HVM domU/ }
    end
  end
end

Facter.add("virtual") do
  confine :kernel => 'SunOS'
  confine :hardwareisa => 'sparc'
  confine :ldom_domainrole_control => 'false'
  has_weight 20 # Weight this before the default solaris implementation
  setcode do
    Facter.value(:ldom_domainrole_impl)
  end
end


Facter.add("virtual") do
  confine :kernel => 'HP-UX'
  has_weight 10
  setcode do
    "hpvm" if Facter::Util::Virtual.hpvm?
  end
end

Facter.add("virtual") do
  confine :architecture => 's390x'
  has_weight 10
  setcode do
    "zlinux" if Facter::Util::Virtual.zlinux?
  end
end

Facter.add("virtual") do
  confine :kernel => 'OpenBSD'
  has_weight 10
  setcode do
    output = Facter::Util::POSIX.sysctl("hw.product")
    if output
      lines = output.split("\n")
      next "parallels"  if lines.any? {|l| l =~ /Parallels/ }
      next "vmware"     if lines.any? {|l| l =~ /VMware/ }
      next "virtualbox" if lines.any? {|l| l =~ /VirtualBox/ }
      next "xenhvm"     if lines.any? {|l| l =~ /HVM domU/ }
      next "ovirt"      if lines.any? {|l| l =~ /oVirt Node/ }
      next "kvm"        if lines.any? {|l| l =~ /KVM/ }
    end
  end
end

Facter.add("virtual") do
  confine :kernel => %w{Linux FreeBSD OpenBSD SunOS HP-UX GNU/kFreeBSD}

  setcode do
    next Facter::Util::Virtual.openvz_type if Facter::Util::Virtual.openvz?
    next Facter::Util::Virtual.vserver_type if Facter::Util::Virtual.vserver?

    if Facter::Util::Virtual.xen?
      next "xen0" if FileTest.exists?("/dev/xen/evtchn")
      next "xenu" if FileTest.exists?("/proc/xen") || FileTest.exists?("/dev/xvda1")
    end

    next "virtualbox" if Facter::Util::Virtual.virtualbox?
    next Facter::Util::Virtual.kvm_type if Facter::Util::Virtual.kvm?
    next "rhev" if Facter::Util::Virtual.rhev?
    next "ovirt" if Facter::Util::Virtual.ovirt?

    # Parse lspci
    output = Facter::Util::Virtual.lspci
    if output
      lines = output.split("\n")
      next "vmware"     if lines.any? {|l| l =~ /VM[wW]are/ }
      next "virtualbox" if lines.any? {|l| l =~ /VirtualBox/ }
      next "parallels"  if lines.any? {|l| l =~ /1ab8:|[Pp]arallels/ }
      next "xenhvm"     if lines.any? {|l| l =~ /XenSource/ }
      next "hyperv"     if lines.any? {|l| l =~ /Microsoft Corporation Hyper-V/ }
      next "gce"        if lines.any? {|l| l =~ /Class 8007: Google, Inc/ }
      next "kvm"        if lines.any? {|l| l =~ /virtio/i }
    end

    # Parse dmidecode
    output = Facter::Core::Execution.exec('dmidecode 2> /dev/null')
    if output
      lines = output.split("\n")
      next "parallels"  if lines.any? {|l| l =~ /Parallels/ }
      next "vmware"     if lines.any? {|l| l =~ /VMware/ }
      next "virtualbox" if lines.any? {|l| l =~ /VirtualBox/ }
      next "xenhvm"     if lines.any? {|l| l =~ /HVM domU/ }
      next "hyperv"     if lines.any? {|l| l =~ /Product Name: Virtual Machine/ }
      next "rhev"       if lines.any? {|l| l =~ /Product Name: RHEV Hypervisor/ }
      next "ovirt"      if lines.any? {|l| l =~ /Product Name: oVirt Node/ }
      next "bochs"      if lines.any? {|l| l =~ /Bochs/ }
      next "kvm"        if lines.any? {|l| l =~ /Manufacturer: QEMU/ }
    end

    # Default to 'physical'
    next 'physical'
  end
end

Facter.add("virtual") do
  confine do
    Facter::Core::Execution.which('vmware')
  end

  setcode do
    # Sample output of vmware -v `VMware Server 1.0.5 build-80187`
    output = Facter::Core::Execution.exec("vmware -v")
    if output
      mdata = output.match /(\S+)\s+(\S+)/
      next "#{mdata[1]}_#{mdata[2]}".downcase if mdata
    end
  end
end

Facter.add("virtual") do
  confine :kernel => "windows"
  setcode do
      require 'facter/util/wmi'
      result = nil
      Facter::Util::WMI.execquery("SELECT manufacturer, model FROM Win32_ComputerSystem").each do |computersystem|
        case computersystem.model
        when /VirtualBox/
          result = "virtualbox"
        when /Virtual Machine/
          result = "hyperv" if computersystem.manufacturer =~ /Microsoft/
        when /VMware/
          result = "vmware"
        when /KVM/
          result = "kvm"
        when /Bochs/
          result = "bochs"
        end

        if result.nil? and computersystem.manufacturer =~ /Xen/
          result = "xen"
        end

        break
      end
      result ||= "physical"

      result
  end
end

##
# virtual fact based on virt-what command.
#
# The output is mapped onto existing known values for the virtual fact in an
# effort to preserve consistency.  This fact has a high weight becuase the
# virt-what tool is expected to be maintained upstream.
#
# If the virt-what command is not available, this fact will not resolve to a
# value and lower-weight virtual facts will be attempted.
#
# Only the last line of the virt-what command is returned
Facter.add("virtual") do
  has_weight 500

  setcode do
    if output = Facter::Util::Virtual.virt_what
      case output
      when 'linux_vserver'
        Facter::Util::Virtual.vserver_type
      when /xen-hvm/i
        'xenhvm'
      when /xen-dom0/i
        'xen0'
      when /xen-domU/i
        'xenu'
      when /ibm_systemz/i
        'zlinux'
      else
        output.to_s.split("\n").last
      end
    end
  end
end

##
# virtual fact specific to Google Compute Engine's Linux sysfs entry.
Facter.add("virtual") do
  has_weight 600
  confine :kernel => "Linux"

  setcode do
    if dmi_data = Facter::Util::Virtual.read_sysfs_dmi_entries
      case dmi_data
      when /Google/
        "gce"
      end
    end
  end
end

##
# virtual fact specific to linux containers.  This also works for Docker
# containers running in lxc.
Facter.add("virtual") do
  has_weight 700
  confine :kernel => "Linux"

  setcode do
    "lxc" if Facter::Util::Virtual.lxc?
  end
end

##
# virtual fact specific to docker containers.
Facter.add("virtual") do
  has_weight 750
  confine :kernel => "Linux"

  setcode do
    "docker" if Facter::Util::Virtual.docker?
  end
end

Facter.add("virtual") do
  has_weight 600
  confine :kernel => "Linux"

  setcode do
    "gce" if Facter::Util::Virtual.gce?
  end
end

Facter.add("is_virtual") do
  confine :kernel => %w{Linux FreeBSD OpenBSD SunOS HP-UX Darwin GNU/kFreeBSD windows}

  setcode do
    physical_types = %w{physical xen0 vmware_server vmware_workstation openvzhn vserver_host}

    if physical_types.include? Facter.value(:virtual)
      false
    else
      true
    end
  end
end
