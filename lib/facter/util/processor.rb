module Facter::Util::Processor
  def self.enum_cpuinfo
    processor_num = -1
    processor_list = []
    cpuinfo = "/proc/cpuinfo"

    if File.exists?(cpuinfo)
      model = Facter.value(:architecture)
      case model
      when "x86_64", "amd64", "i386", /parisc/, "hppa", "ia64"
        Thread::exclusive do
          File.readlines(cpuinfo).each do |l|
            if l =~ /processor\s+:\s+(\d+)/
              processor_num = $1.to_i
            elsif l =~ /model name\s+:\s+(.*)\s*$/
              processor_list[processor_num] = $1 unless processor_num == -1
              processor_num = -1
            elsif l =~ /processor\s+(\d+):\s+(.*)/
              processor_num = $1.to_i
              processor_list[processor_num] = $2 unless processor_num == -1
            end
          end
        end

      when "ppc64"
        Thread::exclusive do
          File.readlines(cpuinfo).each do |l|
            if l =~ /processor\s+:\s+(\d+)/
              processor_num = $1.to_i
            elsif l =~ /cpu\s+:\s+(.*)\s*$/
              processor_list[processor_num] = $1 unless processor_num == -1
              processor_num = -1
            end
          end
        end

      when /arm/
        Thread::exclusive do
          File.readlines(cpuinfo).each do |l|
            if l =~ /Processor\s+:\s+(.+)/
              processor_num += 1
              processor_list[processor_num] = $1.chomp
            elsif l =~ /processor\s+:\s+(\d+)\s*$/
              proc_num = $1.to_i
              if proc_num != 0
                processor_num += 1
                processor_list[processor_num] = processor_list[processor_num-1]
              end
            end
          end
        end

      when /sparc/
        Thread::exclusive do
          File.readlines(cpuinfo).each do |l|
            if l =~ /cpu\s+:\s+(.*)\s*$/
              processor_num += 1
              processor_list[processor_num] = $1
            end
          end
        end
      end
    end
    processor_list
  end

  def self.enum_lsdev
    processor_num = -1
    processor_list = {}
    Thread::exclusive do
      procs = Facter::Util::Resolution.exec('lsdev -Cc processor')
      if procs
        procs.each_line do |proc|
          if proc =~ /^proc(\d+)/
            processor_num = $1.to_i
            # Not retrieving the frequency since AIX 4.3.3 doesn't support the
            # attribute and some people still use the OS.
            proctype = Facter::Util::Resolution.exec('lsattr -El proc0 -a type')
            if proctype =~ /^type\s+(\S+)\s+/
              processor_list[processor_num] = $1
            end
          end
        end
      end
    end
    processor_list
  end
end
