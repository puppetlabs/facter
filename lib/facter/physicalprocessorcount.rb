# Fact: physicalprocessorcount
#
# Purpose: Return the number of physical processors.
#
# Resolution:
#
#   Attempts to use sysfs to get the physical IDs of the processors. Falls
#   back to /proc/cpuinfo and "physical id" if sysfs is not available.
#
# Caveats:
#
Facter.add('physicalprocessorcount') do
  confine :kernel => :linux

  setcode do
    sysfs_cpu_directory = '/sys/devices/system/cpu' # This should always be there ...

    if File.exists?(sysfs_cpu_directory)
      #
      # We assume that the sysfs file system has the correct number of entries
      # under the "/sys/device/system/cpu" directory and if so then we process
      # content of the file "physical_package_id" located inside the "topology"
      # directory in each of the per-CPU sub-directories.
      #
      # As per Linux Kernel documentation and the file "cputopology.txt" located
      # inside the "/usr/src/linux/Documentation" directory we can find following
      # short explanation:
      #
      # (...)
      #
      # 1) /sys/devices/system/cpu/cpuX/topology/physical_package_id:
      #
      #         physical package id of cpuX. Typically corresponds to a physical
      #         socket number, but the actual value is architecture and platform
      #         dependent.
      #
      # (...)
      #
      lookup_pattern = "#{sysfs_cpu_directory}" +
        "/cpu*/topology/physical_package_id"

      Dir.glob(lookup_pattern).collect { |f| Facter::Util::Resolution.exec("cat #{f}")}.uniq.size

    else
      #
      # Try to count number of CPUs using the proc file system next ...
      #
      # We assume that /proc/cpuinfo has what we need and is so then we need
      # to make sure that we only count unique entries ...
      #
      str = Facter::Util::Resolution.exec("grep 'physical.\\+:' /proc/cpuinfo")

      if str then str.scan(/\d+/).uniq.size; end
    end
  end
end

Facter.add('physicalprocessorcount') do
  confine :kernel => :windows
  setcode do
    require 'facter/util/wmi'
    Facter::Util::WMI.execquery("select Name from Win32_Processor").Count
  end
end

Facter.add('physicalprocessorcount') do
  confine :kernel => :sunos

  setcode do
    # (#16526) The -p flag was not added until Solaris 8.  Our intent is to
    # split the kernel release fact value on the dot, take the second element,
    # and disable the -p flag for values < 8 when.
    kernelrelease = Facter.value(:kernelrelease)
    (major_version, minor_version) = kernelrelease.split(".").map { |str| str.to_i }
    cmd = "/usr/sbin/psrinfo"
    result = nil
    if (major_version > 5) or (major_version == 5 and minor_version >= 8) then
      result = Facter::Util::Resolution.exec("#{cmd} -p")
    else
      output = Facter::Util::Resolution.exec(cmd)
      result = output.split("\n").length.to_s
    end
  end
end
