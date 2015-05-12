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
  # lsdev is intended to directly delegate to Facter::Core::Execution.exec in an
  # effort to make the processorX facts easier to test by stubbing only the
  # behaviors we need to stub to get the output of the system command.
  def self.lsdev(command="lsdev -Cc processor")
    Facter::Core::Execution.exec(command)
  end

  ##
  # lsattr is intended to directly delegate to Facter::Core::Execution.exec in
  # an effort to make the processorX facts easier to test.  See also the
  # {lsdev} method.
  def self.lsattr(command="lsattr -El proc0 -a type")
    Facter::Core::Execution.exec(command)
  end

  ##
  # kernel_fact_value is intended to directly delegate to Facter.value(:kernel)
  # to make it easier to stub the kernel fact without affecting the entire
  # system.
  def self.kernel_fact_value
    Facter.value(:kernel)
  end

  ##
  # hpux_processor_list is intended to generate a list of values for the
  # processorX facts.
  def self.hpux_processor_list
    return_value = []
    hpux_proc_id_list = []
    cpu = ""

    ##
    # first, try parsing machinfo output.
    if output = machinfo then
      output.split("\n").each do |line|
        if line.match(/processor model:\s+\d+\s+(.*)/) then
          cpu = $1.to_s
        elsif line.match(/\d+\s+((?:PA-RISC|Intel).*processors.*)/) then
          cpu = $1.to_s
          cpu.sub!(/processors/, "processor")
        elsif line.match(/\s+(Intel.*Processor.*)/) then
          cpu = $1.to_s
        end
      end
    end

    ##
    # if that fails, try looking using model command and cross referencing against
    # sched.models, which could be in three places. This file only catered for
    # PA-RISC. Unfortunately, the file is not up to date sometimes.
    if cpu.empty? then
      m = model
      m.sub!(/\s+$/, "")
      m.sub!(/.*\//, "")
      m.sub!(/.*\s+/, "")

      if sched_models_lines = read_sched_models
        sched_models_lines.each do |l|
          if l.match(m) and l.match(/^\S+\s+\d+\.\d+\s+(\S+)/) then
            cpu = "PA-RISC " + $1.to_s.sub!(/^PA/, "") + " processor"
            break # we assume first match is the only match.
          end
        end
      end
    end

    ##
    # if that also fails, report the CPU version based on unistd.h and chip type based on getconf.
    if cpu.empty? then
      cpu_version = getconf_cpu_version
      cpu_chip_type = getconf_cpu_chip_type
      cpu_string = ""

      if lines = read_unistd_h("/usr/include/sys/unistd.h") then
        lines.each do |l|
          if l.match(/define.*0x#{cpu_version.to_i.to_s(16)}.*\/\*\s+(.*)\s+\*\//) then
            cpu_string = $1.to_s
            break
          end
        end
      end

      if cpu_string.empty? then
        cpu_string = "CPU v" + cpu_version
      end

      cpu = cpu_string + " CHIP TYPE #" + cpu_chip_type
    end

    ##
    # now count (logical) CPUs using ioscan. We set processorX for X in 0..processorcount
    # to cpu as worked out above. HP-UX does not support more than one installed CPU
    # model.
    if output = ioscan then
      output.split("\n").each do |line|
        if line.match(/processor/) then
          hpux_proc_id_list << cpu
        end
      end
    end

    hpux_proc_id_list
  end

  ##
  # read_sched_models is intended to be stubbed instead of File.readlines
  # @return [Array] of strings containing the lines of the file or nil if the
  # sched.models file could not be located.
  def self.read_sched_models
    path = if File.exists?("/usr/lib/sched.models")
             "/usr/lib/sched.models"
           elsif File.exists?("/usr/sam/lib/mo/sched.models")
             "/usr/sam/lib/mo/sched.models"
           elsif File.exists?("/opt/langtools/lib/sched.models")
             "/opt/langtools/lib/sched.models"
           end

    if path
      File.readlines(path)
    end
  end
  private_class_method :read_sched_models

  ##
  # read_unistd_h is intended to be stubbed instead of File.readlines
  # @return [Array] of Strings or nil if the file does not exist.
  def self.read_unistd_h(path)
    if File.exists?(path) then
      File.readlines(path)
    end
  end
  private_class_method :read_unistd_h

  ##
  # machinfo delegates directly to Facter::Core::Execution.exec, as with lsdev
  # above.
  def self.machinfo(command="/usr/contrib/bin/machinfo")
    Facter::Core::Execution.exec(command)
  end

  ##
  # model delegates directly to Facter::Core::Execution.exec.
  def self.model(command="model")
    Facter::Core::Execution.exec(command)
  end

  ##
  # ioscan delegates directly to Facter::Core::Execution.exec.
  def self.ioscan(command="ioscan -fknCprocessor")
    Facter::Core::Execution.exec(command)
  end

  ##
  # getconf_cpu_version delegates directly to Facter::Core::Execution.exec.
  def self.getconf_cpu_version(command="getconf CPU_VERSION")
    Facter::Core::Execution.exec(command)
  end

  ##
  # getconf_cpu_chip_type delegates directly to Facter::Core::Execution.exec.
  def self.getconf_cpu_chip_type(command="getconf CPU_CHIP_TYPE")
    Facter::Core::Execution.exec(command)
  end

  def self.enum_cpuinfo
    processor_num = -1
    processor_list = []
    cpuinfo = "/proc/cpuinfo"

    if File.exists?(cpuinfo)
      model = Facter.value(:architecture)
      case model
      when "x86_64", "amd64", "i386", "x86", /parisc/, "hppa", "ia64"
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

      when "ppc64", "ppc64le"
        File.readlines(cpuinfo).each do |l|
          if l =~ /processor\s+:\s+(\d+)/
            processor_num = $1.to_i
          elsif l =~ /cpu\s+:\s+(.*)\s*$/
            processor_list[processor_num] = $1 unless processor_num == -1
            processor_num = -1
          end
        end

      when /arm/
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

      when /sparc/
        File.readlines(cpuinfo).each do |l|
          if l =~ /cpu\s+:\s+(.*)\s*$/
            processor_num += 1
            processor_list[processor_num] = $1
          end
        end
      end
    end
    processor_list
  end

  def self.enum_kstat
    processor_num = -1
    processor_list = []
    kstat = Facter::Core::Execution.exec('/usr/bin/kstat cpu_info')
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
    processor_list
  end
end
end
end
