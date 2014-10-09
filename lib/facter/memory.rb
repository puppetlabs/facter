# Fact: memory
#
# Purpose: Return information about memory and swap usage.
#
# Resolution:
#   On Linuxes, uses `Facter::Memory.meminfo_number` from
#   `facter/util/memory.rb`
#   On AIX, parses `swap -l` for swap values only.
#   On OpenBSD, it parses `swapctl -l` for swap values, `vmstat` via a module for
#   free memory, and `sysctl hw.physmem` for maximum memory.
#   On FreeBSD, it parses `swapinfo -k` for swap values, and parses `sysctl` for
#   maximum memory.
#   On Solaris, use `swap -l` for swap values, and parsing `prtconf` for maximum
#   memory, and again, the `vmstat` module for free memory.
#
# Caveats:
#   Some BSD platforms aren't covered at all. AIX is missing memory values.
#

# memory.rb
# Additional Facts for memory/swap usage
#
# Copyright (C) 2006 Mooter Media Ltd
# Author: Matthew Palmer <matt@solutionsfirst.com.au>
#
#

require 'facter/util/memory'

[  "memorysize",
   "memoryfree",
   "swapsize",
   "swapfree"
].each do |fact|
  Facter.add(fact) do
    setcode do
      name = Facter.fact(fact + "_mb").value
      Facter::Memory.scale_number(name.to_f, "MB") if name
    end
  end
end

Facter.add("swapsize_mb") do
  setcode do
    swaptotal = Facter::Memory.swap_size
    "%.2f" % [swaptotal] if swaptotal
  end
end

Facter.add("swapfree_mb") do
  setcode do
    swapfree = Facter::Memory.swap_free
    "%.2f" % [swapfree] if swapfree
  end
end

Facter.add("memorysize_mb") do
  setcode do
    memtotal = Facter::Memory.mem_size
    "%.2f" % [memtotal] if memtotal
  end
end

Facter.add("memoryfree_mb") do
  setcode do
    memfree = Facter::Memory.mem_free
    "%.2f" % [memfree] if memfree
  end
end

{   :memorysize_mb => "MemTotal",
    :memoryfree_mb => "MemFree",
    :swapsize_mb   => "SwapTotal",
    :swapfree_mb   => "SwapFree"
}.each do |fact, name|
  Facter.add(fact) do
    confine :kernel => [ :linux, :"gnu/kfreebsd" ]
    setcode do
      meminfo = Facter::Memory.meminfo_number(name)
      "%.2f" % [meminfo]
    end
  end
end

Facter.add("SwapEncrypted") do
  confine :kernel => :openbsd
  setcode do
    sysctl_encrypted = Facter::Util::POSIX.sysctl("vm.swapencrypt.enable").to_i
    !(sysctl_encrypted.zero?)
  end
end

Facter.add("SwapEncrypted") do
  confine :kernel => :Darwin
  setcode do
    swap = Facter::Util::POSIX.sysctl('vm.swapusage')
    encrypted = false
    if swap =~ /\(encrypted\)/ then encrypted = true; end
    encrypted
  end
end

if Facter.value(:kernel) == "SunOS"

  Facter.add("memorysize_mb") do
    confine :kernel => :sunos
    # Total memory size available from prtconf
    pconf = Facter::Core::Execution.exec('/usr/sbin/prtconf 2>/dev/null')
    phymem = ""
    pconf.each_line do |line|
      if line =~ /^Memory size:\s+(\d+) Megabytes/
        phymem = $1
      end
    end
    setcode do
      "%.2f" % [phymem.to_f]
    end
  end
end

if Facter.value(:kernel) == "windows"
  require 'facter/util/wmi'

  Facter.add("memorysize_mb") do
    confine :kernel => :windows
    setcode do
      mem = 0
      Facter::Util::WMI.execquery("select TotalPhysicalMemory from Win32_ComputerSystem").each do |comp|
        mem = comp.TotalPhysicalMemory
        break
      end
      "%.2f" % [(mem.to_f / 1024.0) / 1024.0]
    end
  end

  Facter.add("memoryfree_mb") do
    confine :kernel => :windows
    setcode do
      mem = 0
      Facter::Util::WMI.execquery("select FreePhysicalMemory from Win32_OperatingSystem").each do |os|
        mem = os.FreePhysicalMemory
        break
      end
      "%.2f" % [mem.to_f / 1024.0]
    end
  end
end

Facter.add("swapsize_mb") do
  confine :kernel => :dragonfly
  setcode do
    page_size = Facter::Util::POSIX.sysctl("hw.pagesize").to_f
    swaptotal = Facter::Util::POSIX.sysctl("vm.swap_size").to_f * page_size
    "%.2f" % [(swaptotal.to_f / 1024.0) / 1024.0]
  end
end

Facter.add("swapfree_mb") do
  confine :kernel => :dragonfly
  setcode do
    page_size = Facter::Util::POSIX.sysctl("hw.pagesize").to_f
    swaptotal = Facter::Util::POSIX.sysctl("vm.swap_size").to_f * page_size
    swap_anon_use = Facter::Util::POSIX.sysctl("vm.swap_anon_use").to_f * page_size
    swap_cache_use = Facter::Util::POSIX.sysctl("vm.swap_cache_use").to_f * page_size
    swapfree = swaptotal - swap_anon_use - swap_cache_use
    "%.2f" % [(swapfree.to_f / 1024.0) / 1024.0]
  end
end
