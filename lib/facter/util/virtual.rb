require 'facter/util/posix'
require 'facter/util/file_read'
require 'pathname'

module Facter::Util::Virtual
  ##
  # virt_what is a delegating helper method intended to make it easier to stub
  # the system call without affecting other calls to
  # Facter::Core::Execution.exec
  #
  # Per https://bugzilla.redhat.com/show_bug.cgi?id=719611 when run as a
  # non-root user the virt-what command may emit an error message on stdout,
  # and later versions of virt-what may emit this message on stderr. This
  # method ensures stderr is redirected and that error messages are stripped
  # from stdout.
  def self.virt_what(cmd = "virt-what")
    if bindir = Facter::Util::Config.override_binary_dir
      command = Facter::Core::Execution.which(File.join(bindir, cmd))
    else
      command = nil
    end

    if !command
      command = Facter::Core::Execution.which(cmd)
      return unless command
    end

    if Facter.value(:kernel) == 'windows'
      redirected_cmd = "#{command} 2>NUL"
    else
      redirected_cmd = "#{command} 2>/dev/null"
    end
    output = Facter::Core::Execution.exec redirected_cmd
    output.gsub(/^virt-what: .*$/, '') if output
  end

  ##
  # lspci is a delegating helper method intended to make it easier to stub the
  # system call without affecting other calls to Facter::Core::Execution.exec
  def self.lspci(command = nil)
    if command.nil?
      if ["FreeBSD", "OpenBSD"].include? Facter.value(:kernel)
        command = "pciconf -lv 2>/dev/null"
      else
        command = "lspci 2>/dev/null"
      end
    end

    Facter::Core::Execution.exec command
  end

  def self.openvz?
    FileTest.directory?("/proc/vz") and not self.openvz_cloudlinux?
  end

  # So one can either have #6728 work on OpenVZ or Cloudlinux. Whoo.
  def self.openvz_type
    return false unless self.openvz?
    return false unless FileTest.exists?( '/proc/self/status' )

    envid = Facter::Core::Execution.exec( 'grep "envID" /proc/self/status' )
    if envid =~ /^envID:\s+0$/i
    return 'openvzhn'
    elsif envid =~ /^envID:\s+(\d+)$/i
    return 'openvzve'
    end
  end

  # Cloudlinux uses OpenVZ to a degree, but always has an empty /proc/vz/ and
  # has /proc/lve/list present
  def self.openvz_cloudlinux?
    FileTest.file?("/proc/lve/list") or Dir.glob('/proc/vz/*').empty?
  end

  def self.zone?
    return true if FileTest.directory?("/.SUNWnative")
    z = Facter::Core::Execution.exec("/sbin/zonename")
    return false unless z
    return z.chomp != 'global'
  end

  def self.vserver?
    return false unless FileTest.exists?("/proc/self/status")
    txt = File.open("/proc/self/status", "rb").read
    if txt.respond_to?(:encode!)
      txt.encode!('UTF-16', 'UTF-8', :invalid => :replace)
      txt.encode!('UTF-8', 'UTF-16')
    end
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
     elsif ["FreeBSD", "OpenBSD"].include? Facter.value(:kernel)
       Facter::Util::POSIX.sysctl("hw.model")
     elsif Facter.value(:kernel) == "SunOS" and FileTest.exists?("/usr/sbin/prtconf")
       Facter::Core::Execution.exec("/usr/sbin/prtconf -v")
     end
     (txt =~ /QEMU Virtual (CPU|Machine)/i) ? true : false
  end

  def self.virtualbox?
    File.read("/sys/devices/virtual/dmi/id/product_name") =~ /VirtualBox/ rescue false
  end

  def self.kvm_type
    # TODO Tell the difference between kvm and qemu
    # Can't work out a way to do this at the moment that doesn't
    # require a special binary
    if self.kvm?
      "kvm"
    end
  end

  def self.rhev?
    File.read("/sys/devices/virtual/dmi/id/product_name") =~ /RHEV Hypervisor/ rescue false
  end

  def self.ovirt?
    File.read("/sys/devices/virtual/dmi/id/product_name") =~ /oVirt Node/ rescue false
  end

  def self.gce?
    File.read("/sys/devices/virtual/dmi/id/product_name") =~ /Google/ rescue false
  end

  def self.jail?
    path = case Facter.value(:kernel)
      when "FreeBSD" then "/sbin"
      when "GNU/kFreeBSD" then "/bin"
    end
    Facter::Core::Execution.exec("#{path}/sysctl -n security.jail.jailed") == "1"
  end

  def self.hpvm?
    Facter::Core::Execution.exec("/usr/bin/getconf MACHINE_MODEL").chomp =~ /Virtual Machine/
  end

  ##
  # lxc? returns true if the process is running inside of a linux container.
  # Implementation derived from
  # http://stackoverflow.com/questions/20010199/determining-if-a-process-runs-inside-lxc-docker
  def self.lxc?
    path = Pathname.new('/proc/1/cgroup')
    return false unless path.readable?
    begin
      in_lxc = path.readlines.any? {|l| l.split(":")[2].to_s.include? '/lxc' }
    rescue Errno::EPERM => exc
      # If we get "operation not permitted" here, it probably means we are
      # running OpenVZ. We are not running LXC anyway, so...
      return false
    end
    return true if in_lxc
    return false
  end

  ##
  # docker? returns true if the process is running inside of a docker container.
  # Implementation derived from observation of a boot2docker system
  def self.docker?
    path = Pathname.new('/proc/1/cgroup')
    return false unless path.readable?
    begin
      in_docker = path.readlines.any? {|l| l.split(":")[2].to_s.include? '/docker' }
    rescue Errno::EPERM => exc
      # This can fail under OpenVZ, just like in .lxc?
      return false
    end
    return true if in_docker
    return false
  end

  def self.zlinux?
    "zlinux"
  end

  ##
  # read_sysfs Reads the raw data as per the documentation at [Detecting if You
  # Are Running in Google Compute
  # Engine](https://developers.google.com/compute/docs/instances#dmi)  This
  # method is intended to provide an easy seam to mock.
  #
  # @api public
  #
  # @return [String] or nil if the path does not exist or is unreadable
  def self.read_sysfs_dmi_entries(path="/sys/firmware/dmi/entries/1-0/raw")
    if File.readable?(path)
      begin
        Facter::Util::FileRead.read_binary(path)
      rescue Errno::EINVAL
      end
    end
  end
end
