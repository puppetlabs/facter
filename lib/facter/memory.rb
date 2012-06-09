# Fact: memory
#
# Purpose: Return information about memory and swap usage.
#
# Resolution:
#   On Linuxes, uses Facter::Memory.meminfo_number from
#   'facter/util/memory.rb'
#   On AIX, parses "swap -l" for swap values only.
#   On OpenBSD, it parses "swapctl -l" for swap values, vmstat via a module for
#   free memory, and "sysctl hw.physmem" for maximum memory.
#   On FreeBSD, it parses "swapinfo -k" for swap values, and parses sysctl for
#   maximum memory.
#   On Solaris, use "swap -l" for swap values, and parsing prtconf for maximum
#   memory, and again, the vmstat module for free memory.
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

{   :MemorySize => "MemTotal",
    :MemoryFree => "MemFree",
    :SwapSize   => "SwapTotal",
    :SwapFree   => "SwapFree"
}.each do |fact, name|
  Facter.add(fact) do
    confine :kernel => [ :linux, :"gnu/kfreebsd" ]
    setcode do
      Facter::Memory.meminfo_number(name)
    end
  end
end

[  "memorysize",
   "memoryfree",
   "swapsize",
   "swapfree"
].each do |fact|
  Facter.add(fact) do
    setcode do
      name = Facter.fact(fact + "_mb").value
      Facter::Memory.scale_number(name.to_f, "MB")
    end
  end
end

Facter.add("swapsize_mb") do
  setcode do
    swaptotal = Facter::Memory.swap_size
    "%.2f" % [swaptotal]
  end
end

Facter.add("swapfree_mb") do
  setcode do
    swapfree = Facter::Memory.swap_free
    "%.2f" % [swapfree]
  end
end


if Facter.value(:kernel) == "AIX" and Facter.value(:id) == "root"
  swap = Facter::Util::Resolution.exec('swap -l')
  swapfree, swaptotal = 0, 0
  swap.each_line do |dev|
    if dev =~ /^\/\S+\s.*\s+(\S+)MB\s+(\S+)MB/
      swaptotal += $1.to_i
      swapfree  += $2.to_i
    end
  end

  Facter.add("swapsize_mb") do
    confine :kernel => :aix
    setcode do
      "%.2f" % [swaptotal.to_f]
    end
  end

  Facter.add("swapfree_mb") do
    confine :kernel => :aix
    setcode do
      "%.2f" % [swapfree.to_f]
    end
  end
end

if Facter.value(:kernel) == "OpenBSD"
  Facter.add("memorysize_mb") do
    confine :kernel => :openbsd
    memtotal = Facter::Util::Resolution.exec("sysctl hw.physmem | cut -d'=' -f2")
    setcode do
      "%.2f" % [(memtotal.to_f / 1024.0) / 1024.0]
    end
  end

  Facter.add("memoryfree_mb") do
    confine :kernel => :openbsd
    setcode do
      Facter::Memory.vmstat_find_free_memory()
    end
  end
end

if Facter.value(:kernel) == "FreeBSD"
  Facter.add("memorysize_mb") do
    confine :kernel => :freebsd
    memtotal = Facter::Util::Resolution.exec("sysctl -n hw.physmem")
    setcode do
      "%.2f" % [(memtotal.to_f / 1024.0) / 1024.0]
    end
  end

  # FreeBSD had to be different and be default prints human readable
  # format instead of machine readable. So using 'vmstat -H' instead
  # Facter::Memory.vmstat_find_free_memory()

  Facter.add("memoryfree_mb") do
    confine :kernel => :freebsd
    setcode do
      Facter::Memory.vmstat_find_free_memory(["-H"])
    end
  end
end

if Facter.value(:kernel) == "Darwin"

  Facter.add("memorysize_mb") do
    confine :kernel => :Darwin
    memtotal = Facter::Util::Resolution.exec("sysctl -n hw.memsize")
    setcode do
      "%.2f" % [(memtotal.to_f / 1024.0) / 1024.0]
    end
  end

  Facter.add("memoryfree_mb") do
    confine :kernel => :Darwin
    freemem = Facter::Memory.vmstat_darwin_find_free_memory()
    setcode do
      "%.2f" % [(freemem.to_f / 1024.0) / 1024.0]
    end
  end

  Facter.add("SwapEncrypted") do
    confine :kernel => :Darwin
    setcode do
      swap = Facter::Util::Resolution.exec('sysctl vm.swapusage')
      encrypted = false
      if swap =~ /\(encrypted\)/ then encrypted = true; end
      encrypted
    end
  end
end

if Facter.value(:kernel) == "SunOS"
  # Total memory size available from prtconf
  pconf = Facter::Util::Resolution.exec('/usr/sbin/prtconf 2>/dev/null')
  phymem = ""
  pconf.each_line do |line|
    if line =~ /^Memory size:\s+(\d+) Megabytes/
      phymem = $1
    end
  end

  Facter.add("memorysize_mb") do
    confine :kernel => :sunos
    setcode do
      "%.2f" % [phymem.to_f]
    end
  end

  Facter.add("memoryfree_mb") do
    confine :kernel => :sunos
    setcode do
      Facter::Memory.vmstat_find_free_memory()
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
#    swaptotal = Facter::Memory.swap_total_dragonfly()
    page_size = Facter::Util::Resolution.exec("/sbin/sysctl -n hw.pagesize").to_f
    swaptotal = Facter::Util::Resolution.exec("/sbin/sysctl -n vm.swap_size").to_f * page_size
    "%.2f" % [(swaptotal.to_f / 1024.0) / 1024.0]
  end
end

Facter.add("swapfree_mb") do
  confine :kernel => :dragonfly
  setcode do
    page_size = Facter::Util::Resolution.exec("/sbin/sysctl -n hw.pagesize").to_f
    swaptotal = Facter::Util::Resolution.exec("/sbin/sysctl -n vm.swap_size").to_f * page_size
    swap_anon_use = Facter::Util::Resolution.exec("/sbin/sysctl -n vm.swap_anon_use").to_f * page_size
    swap_cache_use = Facter::Util::Resolution.exec("/sbin/sysctl -n vm.swap_cache_use").to_f * page_size
    swapfree = swaptotal - swap_anon_use - swap_cache_use
    "%.2f" % [(swapfree.to_f / 1024.0) / 1024.0]
  end
end

Facter.add("memorysize_mb") do
  confine :kernel => :dragonfly
  setcode do
    memtotal = Facter::Util::Resolution.exec("sysctl -n hw.physmem")
    "%.2f" % [(memtotal.to_f / 1024.0) / 1024.0]
  end
end

if Facter.value(:kernel) == "dragonfly"
  Facter.add("memoryfree_mb") do
    confine :kernel => :dragonfly
    setcode do
      Facter::Memory.vmstat_find_free_memory()
    end
  end
end
