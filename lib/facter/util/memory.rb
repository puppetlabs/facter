## memory.rb
## Support module for memory related facts
##

module Facter::Memory
  require 'thread'

  def self.meminfo_number(tag)
    memsize = ""
    Thread::exclusive do
      size, scale = [0, ""]
      File.readlines("/proc/meminfo").each do |l|
        size, scale = [$1.to_f, $2] if l =~ /^#{tag}:\s+(\d+)\s+(\S+)/
        # MemoryFree == memfree + cached + buffers
        #  (assume scales are all the same as memfree)
        if tag == "MemFree" &&
          l =~ /^(?:Buffers|Cached):\s+(\d+)\s+(?:\S+)/
          size += $1.to_f
        end
      end
      memsize = scale_number(size, scale)
    end

    memsize
  end

  def self.scale_number(size, multiplier)
    suffixes = ['', 'kB', 'MB', 'GB', 'TB']

    s = suffixes.shift
    while s != multiplier
      s = suffixes.shift
    end

    while size > 1024.0
      size /= 1024.0
      s = suffixes.shift
    end

    return "%.2f %s" % [size, s]
  end

  def self.vmstat_find_free_memory()
    row = Facter::Util::Resolution.exec('vmstat').split("\n")[-1]
    if row =~ /^\s*\d+\s*\d+\s*\d+\s*\d+\s*(\d+)/
      Facter.add("MemoryFree") do
        memfree = $1
        setcode do
          Facter::Memory.scale_number(memfree.to_f, "kB")
        end
      end
    end
  end

  # Darwin had to be different. It's generally opaque with how much RAM it is
  # using, and this figure could be improved upon too I fear.
  # Parses the output of "vm_stat", takes the pages free & pages speculative
  # and multiples that by the page size (also given in output). Ties in with
  # what activity monitor outputs for free memory.
  def self.vmstat_darwin_find_free_memory()

    memfree = 0
    pagesize = 0
    memspecfree = 0

    vmstats = Facter::Util::Resolution.exec('vm_stat')
    vmstats.each_line do |vmline|
      case
      when vmline =~ /page\ssize\sof\s(\d+)\sbytes/
        pagesize = $1.to_i
      when vmline =~ /^Pages\sfree:\s+(\d+)\./
        memfree = $1.to_i
      when vmline =~ /^Pages\sspeculative:\s+(\d+)\./
        memspecfree = $1.to_i
      end
    end

    freemem = ( memfree + memspecfree ) * pagesize
    Facter.add("MemoryFree") do
      setcode do
        Facter::Memory.scale_number(freemem.to_f, "")
      end
    end
  end
end
