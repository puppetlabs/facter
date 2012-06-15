## memory.rb
## Support module for memory related facts
##

module Facter::Memory
  def self.meminfo_number(tag)
    memsize = ""
    size = [0]
    File.readlines("/proc/meminfo").each do |l|
      size = $1.to_f if l =~ /^#{tag}:\s+(\d+)\s+\S+/
      if tag == "MemFree" &&
          l =~ /^(?:Buffers|Cached):\s+(\d+)\s+\S+/
        size += $1.to_f
      end
    end
    size / 1024.0
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

    "%.2f %s" % [size, s]
  end

  def self.vmstat_find_free_memory(args = [])
    cmd = 'vmstat'
    cmd += (' ' + args.join(' ')) unless args.empty?
    row = Facter::Util::Resolution.exec(cmd).split("\n")[-1]
    if row =~ /^\s*\d+\s*\d+\s*\d+\s*\d+\s*(\d+)/
      memfree = $1
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
  end

  def self.mem_free(kernel = Facter.value(:kernel))
    output = mem_free_info(kernel)
    scale_mem_free_value output, kernel
  end

  def self.mem_free_info(kernel = Facter.value(:kernel))
    case kernel
    when /OpenBSD/i, /SunOS/i, /Dragonfly/i
      vmstat_find_free_memory()
    when /FreeBSD/i
      vmstat_find_free_memory(["-H"])
    when /Darwin/i
      vmstat_darwin_find_free_memory()
    end
  end

  def self.scale_mem_free_value (value, kernel)
    case kernel
    when /OpenBSD/i, /FreeBSD/i, /SunOS/i, /Dragonfly/i
      value.to_f / 1024.0
    when /Darwin/i
      value.to_f / 1024.0 / 1024.0
    else
      value.to_f
    end
 end

  def self.mem_size(kernel = Facter.value(:kernel))
    output = mem_size_info(kernel)
    scale_mem_size_value output, kernel
  end

  def self.mem_size_info(kernel = Facter.value(:kernel))
    case kernel
    when /OpenBSD/i
      Facter::Util::Resolution.exec("sysctl hw.physmem | cut -d'=' -f2")
    when /FreeBSD/i
      Facter::Util::Resolution.exec("sysctl -n hw.physmem")
    when /Darwin/i
      Facter::Util::Resolution.exec("sysctl -n hw.memsize")
    when /Dragonfly/i
      Facter::Util::Resolution.exec("sysctl -n hw.physmem")
    end
  end

  def self.scale_mem_size_value(value, kernel)
    case kernel
    when /OpenBSD/i, /FreeBSD/i, /Darwin/i, /Dragonfly/i
      value.to_f / 1024.0 / 1024.0
    else
      value.to_f
    end
  end

  def self.swap_size(kernel = Facter.value(:kernel))
    output = swap_info(kernel)
    parse_swap output, kernel, :size if output
  end

  def self.swap_free(kernel = Facter.value(:kernel))
    output = swap_info(kernel)
    parse_swap output, kernel, :free if output
  end

  def self.swap_info(kernel = Facter.value(:kernel))
    case kernel
    when /AIX/i
      (Facter.value(:id) == "root") ? Facter::Util::Resolution.exec('swap -l') : nil
    when /OpenBSD/i
      Facter::Util::Resolution.exec('swapctl -s')
    when /FreeBSD/i
      Facter::Util::Resolution.exec('swapinfo -k')
    when /Darwin/i
      Facter::Util::Resolution.exec('sysctl vm.swapusage')
    when /SunOS/i
      Facter::Util::Resolution.exec('/usr/sbin/swap -l')
    end
  end

  def self.parse_swap (output, kernel = Facter.value(:kernel), size_or_free = :size)
    value_in_mb = 0.0
    value = 0
    is_size = size_or_free == :size
    unless output.nil?
      output.each_line do |line|
        value += parse_swap_line(line, kernel, is_size)
      end
    end      
    value_in_mb = scale_swap_value(value, kernel)
  end

  # There is a lot of duplication here because of concern over being able to add
  # new platforms in a reasonable manner. For all of these platforms the first
  # regex corresponds to the swap size value and the second corresponds to the swap
  # free value, but this may not always be the case. In Ruby 1.9.3 it is possible
  # to give these names, but sadly 1.8.7 does not support this.
 
  def self.parse_swap_line(line, kernel, is_size)
    case kernel
    when /AIX/i
      if line =~ /^\/\S+\s.*\s+(\S+)MB\s+(\S+)MB/
        (is_size) ? $1.to_i : $2.to_i
      else
        0
      end
    when /OpenBSD/i
      if line =~ /^total: (\d+)k bytes allocated = \d+k used, (\d+)k available$/
        (is_size) ? $1.to_i : $2.to_i
      else
        0
      end
    when /FreeBSD/i
      if line =~ /\S+\s+(\d+)\s+\d+\s+(\d+)\s+\d+%$/
        (is_size) ? $1.to_i : $2.to_i
      else
        0
      end
    when /Darwin/i
      if line =~ /total\s=\s(\S+)M\s+used\s=\s\S+M\s+free\s=\s(\S+)M\s/
        (is_size) ? $1.to_i : $2.to_i
      else
        0
      end
    when /SunOS/i
      if line =~ /^\/\S+\s.*\s+(\d+)\s+(\d+)$/
        (is_size) ? $1.to_i : $2.to_i
      else
        0
      end
    end
  end

  def self.scale_swap_value(value, kernel)
    case kernel
    when /OpenBSD/i, /FreeBSD/i
      value.to_f / 1024.0
    when /SunOS/i
      value.to_f / 2 / 1024.0
    else
      value.to_f
    end
  end
end
