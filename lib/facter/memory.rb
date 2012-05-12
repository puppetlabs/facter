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

Facter.add("SwapSize") do
  confine :kernel => :Darwin
  setcode do
    swap = Facter::Util::Resolution.exec('sysctl vm.swapusage')
    swaptotal = 0
    if swap =~ /total = (\S+)/ then swaptotal = $1; end
    swaptotal
  end
end

Facter.add("SwapFree") do
  confine :kernel => :Darwin
  setcode do
    swap = Facter::Util::Resolution.exec('sysctl vm.swapusage')
    swapfree = 0
    if swap =~ /free = (\S+)/ then swapfree = $1; end
    swapfree
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

if Facter.value(:kernel) == "AIX" and Facter.value(:id) == "root"
  swap = Facter::Util::Resolution.exec('swap -l')
  swapfree, swaptotal = 0, 0
  swap.each_line do |dev|
    if dev =~ /^\/\S+\s.*\s+(\S+)MB\s+(\S+)MB/
      swaptotal += $1.to_i
      swapfree  += $2.to_i
    end
  end

  Facter.add("SwapSize") do
    confine :kernel => :aix
    setcode do
      Facter::Memory.scale_number(swaptotal.to_f,"MB")
    end
  end

  Facter.add("SwapFree") do
    confine :kernel => :aix
    setcode do
      Facter::Memory.scale_number(swapfree.to_f,"MB")
    end
  end
end

if Facter.value(:kernel) == "OpenBSD"
  swap = Facter::Util::Resolution.exec('swapctl -s')
  swapfree, swaptotal = 0, 0
  if swap =~ /^total: (\d+)k bytes allocated = \d+k used, (\d+)k available$/
    swaptotal = $1.to_i
    swapfree  = $2.to_i
  end

  Facter.add("SwapSize") do
    confine :kernel => :openbsd
    setcode do
      Facter::Memory.scale_number(swaptotal.to_f,"kB")
    end
  end

  Facter.add("SwapFree") do
    confine :kernel => :openbsd
    setcode do
      Facter::Memory.scale_number(swapfree.to_f,"kB")
    end
  end

  Facter::Memory.vmstat_find_free_memory()

  Facter.add("memorysize") do
    confine :kernel => :openbsd
    memtotal = Facter::Util::Resolution.exec("sysctl hw.physmem | cut -d'=' -f2")
    setcode do
      Facter::Memory.scale_number(memtotal.to_f,"")
    end
  end
end

if Facter.value(:kernel) == "Darwin"
  swap = Facter::Util::Resolution.exec('sysctl vm.swapusage')
  swapfree, swaptotal = 0, 0
  unless swap.empty?
    # Parse the line:
    # vm.swapusage: total = 128.00M  used = 0.37M  free = 127.63M  (encrypted)
    if swap =~ /total\s=\s(\S+)\s+used\s=\s(\S+)\s+free\s=\s(\S+)\s/
      swaptotal += $1.to_i
      swapfree  += $3.to_i
    end
  end

  Facter.add("SwapSize") do
    confine :kernel => :Darwin
    setcode do
      Facter::Memory.scale_number(swaptotal.to_f,"MB")
    end
  end

  Facter.add("SwapFree") do
    confine :kernel => :Darwin
    setcode do
      Facter::Memory.scale_number(swapfree.to_f,"MB")
    end
  end

  Facter::Memory.vmstat_darwin_find_free_memory()

  Facter.add("memorysize") do
    confine :kernel => :Darwin
    memtotal = Facter::Util::Resolution.exec("sysctl hw.memsize | cut -d':' -f2")
    setcode do
      Facter::Memory.scale_number(memtotal.to_f,"")
    end
  end
end

if Facter.value(:kernel) == "SunOS"
  swap = Facter::Util::Resolution.exec('/usr/sbin/swap -l')
  swapfree, swaptotal = 0, 0
  swap.each_line do |dev|
    if dev =~ /^\/\S+\s.*\s+(\d+)\s+(\d+)$/
      swaptotal += $1.to_i / 2
      swapfree  += $2.to_i / 2
    end
  end

  Facter.add("SwapSize") do
    confine :kernel => :sunos
    setcode do
      Facter::Memory.scale_number(swaptotal.to_f,"kB")
    end
  end

  Facter.add("SwapFree") do
    confine :kernel => :sunos
    setcode do
      Facter::Memory.scale_number(swapfree.to_f,"kB")
    end
  end

  # Total memory size available from prtconf
  pconf = Facter::Util::Resolution.exec('/usr/sbin/prtconf 2>/dev/null')
  phymem = ""
  pconf.each_line do |line|
    if line =~ /^Memory size:\s+(\d+) Megabytes/
      phymem = $1
    end
  end

  Facter.add("MemorySize") do
    confine :kernel => :sunos
    setcode do
      Facter::Memory.scale_number(phymem.to_f,"MB")
    end
  end

  Facter::Memory.vmstat_find_free_memory()
end

if Facter.value(:kernel) == "windows"
  require 'facter/util/wmi'

  Facter.add("MemoryFree") do
    confine :kernel => :windows
    setcode do
      mem = 0
      Facter::Util::WMI.execquery("select FreePhysicalMemory from Win32_OperatingSystem").each do |os|
        mem = os.FreePhysicalMemory
        break
      end
      Facter::Memory.scale_number(mem.to_f, "kB")
    end
  end

  Facter.add("memorysize") do
    confine :kernel => :windows
    setcode do
      mem = 0
      Facter::Util::WMI.execquery("select TotalPhysicalMemory from Win32_ComputerSystem").each do |comp|
        mem = comp.TotalPhysicalMemory
        break
      end
      Facter::Memory.scale_number(mem.to_f, "")
    end
  end
end

Facter.add("SwapSize") do
  confine :kernel => :dragonfly
  setcode do
    page_size = Facter::Util::Resolution.exec("/sbin/sysctl -n hw.pagesize").to_f
    swaptotal = Facter::Util::Resolution.exec("/sbin/sysctl -n vm.swap_size").to_f * page_size
    Facter::Memory.scale_number(swaptotal.to_f,"")
  end
end

Facter.add("SwapFree") do
  confine :kernel => :dragonfly
  setcode do
    page_size = Facter::Util::Resolution.exec("/sbin/sysctl -n hw.pagesize").to_f
    swaptotal = Facter::Util::Resolution.exec("/sbin/sysctl -n vm.swap_size").to_f * page_size
    swap_anon_use = Facter::Util::Resolution.exec("/sbin/sysctl -n vm.swap_anon_use").to_f * page_size
    swap_cache_use = Facter::Util::Resolution.exec("/sbin/sysctl -n vm.swap_cache_use").to_f * page_size
    swapfree = swaptotal - swap_anon_use - swap_cache_use
    Facter::Memory.scale_number(swapfree.to_f,"")
  end
end

Facter.add("memorysize") do
  confine :kernel => :dragonfly
  setcode do
    Facter::Memory.vmstat_find_free_memory()
    memtotal = Facter::Util::Resolution.exec("sysctl -n hw.physmem")
    Facter::Memory.scale_number(memtotal.to_f,"")
  end
end