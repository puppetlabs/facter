module Facter
module Util
module Processor
  ##
  # aix_processor_list is intended to generate a list of values for the
  # processorX facts.  The behavior is as follows from
  # [#11609](http://projects.puppetlabs.com/issues/11609)
  #
  # 1. Take a list of all the processor identifiers for the platform,
  #    represented as system-native identifiers in strings.
  # 2. Sort the list
  # 3. Assign an incrementing from 0 integer index to each identifier.
  # 4. Store the value of the system identifier in the processorX fact where X
  #    is the incrementing index.
  #
  # Returns an Array, sorted, containing the values for the facts.
  def self.aix_processor_list
    return_value = []
    aix_proc_id_list = []

    if output = lsdev then
      output.split("\n").each do |line|
        if match = line.match(/proc\d+/)
          aix_proc_id_list << match[0]
        end
      end
    end

    # Generalized alphanumeric sort to put "proc12" behind "proc4"
    padding = 8
    aix_proc_id_list = aix_proc_id_list.sort do |a,b|
      a,b = [a,b].map do |s|
        s.gsub(/\d+/) { |m| "0"*(padding - m.size) + m }
      end
      a<=>b
    end

    aix_proc_id_list.each do |proc_id|
      if output = lsattr("lsattr -El #{proc_id} -a type")
        if match = output.match(/type\s+([^\s]+)\s+Processor/i)
          return_value << match[1]
        end
      end
    end

    return_value
  end

  ##
  # lsdev is intended to directly delegate to Facter::Util::Resolution.exec in an
  # effort to make the processorX facts easier to test by stubbing only the
  # behaviors we need to stub to get the output of the system command.
  def self.lsdev(command="lsdev -Cc processor")
    Facter::Util::Resolution.exec(command)
  end

  ##
  # lsattr is intended to directly delegate to Facter::Util::Resolution.exec in
  # an effort to make the processorX facts easier to test.  See also the
  # {lsdev} method.
  def self.lsattr(command="lsattr -El proc0 -a type")
    Facter::Util::Resolution.exec(command)
  end

  ##
  # kernel_fact_value is intended to directly delegate to Facter.value(:kernel)
  # to make it easier to stub the kernel fact without affecting the entire
  # system.
  def self.kernel_fact_value
    Facter.value(:kernel)
  end

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

  def self.enum_kstat
    processor_num = -1
    processor_list = []
    Thread::exclusive do
      kstat = Facter::Util::Resolution.exec('/usr/bin/kstat cpu_info')
      if kstat
        kstat.each_line do |l|
          if l =~ /cpu_info(\d+)/
            processor_num = $1.to_i
          elsif l =~ /brand\s+(.*)\s*$/
            processor_list[processor_num] = $1 unless processor_num == -1
            processor_num = -1
          end
        end
      end
    end
    processor_list
  end
end
end
end
