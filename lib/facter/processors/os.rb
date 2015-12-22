# Processor OS classes
#
# Implements processor data collection with the help
# of the Util::Processor module.

require 'facter/util/processor'
require 'facter/util/posix'

module Facter
  module Processors

    def self.implementation(kernel = Facter.value(:kernel))
      case kernel
      when "Linux"
        Facter::Processors::Linux.new
      when "GNU/kFreeBSD"
        Facter::Processors::GNU.new
      when "Darwin"
        Facter::Processors::Darwin.new
      when "AIX"
        Facter::Processors::AIX.new
      when "HP-UX"
        Facter::Processors::HP_UX.new
      when "DragonFly", "FreeBSD"
        Facter::Processors::BSD.new
      when "OpenBSD"
        Facter::Processors::OpenBSD.new
      when "SunOS"
        Facter::Processors::SunOS.new
      when "windows"
        Facter::Processors::Windows.new
      end
    end

    class Base
      def get_processor_list
        Facter::Util::Processor.enum_cpuinfo
      end

      def get_processor_count
        get_processor_list.length
      end

      def get_physical_processor_count
        nil
      end

      def get_processor_speed
        nil
      end
    end

    class GNU < Base
      def get_processor_count
        processor_list = get_processor_list
        if processor_list.length != 0
          processor_list.length
        else
          count_cpu_from_sysfs
        end
      end

      private

      def count_cpu_from_sysfs
        sysfs_cpu_directory = "/sys/devices/system/cpu"
        if File.exists?(sysfs_cpu_directory)
          lookup_pattern = "#{sysfs_cpu_directory}" + "/cpu[0-9]*"
          Dir.glob(lookup_pattern).length
        end
      end
    end

    class Linux < GNU
      def get_physical_processor_count
        if count = count_physical_cpu_from_sysfs
          count
        else
          count_physical_cpu_from_cpuinfo
        end
      end

      private

      def count_physical_cpu_from_sysfs
        sysfs_cpu_directory = "/sys/devices/system/cpu"
        if File.exists?(sysfs_cpu_directory)
          lookup_pattern = "#{sysfs_cpu_directory}" + "/cpu*/topology/physical_package_id"
          Dir.glob(lookup_pattern).collect { |f| Facter::Core::Execution.exec("cat #{f}")}.uniq.size
        else
          nil
        end
      end

      def count_physical_cpu_from_cpuinfo
        str = Facter::Core::Execution.exec("grep 'physical.\+:' /proc/cpuinfo")
        if str
          str.scan(/\d+/).uniq.size
        else
          nil
        end
      end
    end

    class Windows < Base
      def initialize
        require 'facter/util/wmi'
      end

      def get_processor_list
        processor_list = []
        # get each physical processor
        Facter::Util::WMI.execquery("select * from Win32_Processor").each do |proc|
          # not supported before 2008
          if proc.ole_respond_to?(:NumberOfLogicalProcessors)
            processor_num = proc.NumberOfLogicalProcessors
          else
            processor_num = 1
          end

          processor_num.times do |i|
            processor_list << proc.Name.squeeze(" ")
          end
        end
        processor_list
      end

      def get_physical_processor_count
         Facter::Util::WMI.execquery("select Name from Win32_Processor").Count
      end
    end

    class AIX < Base
      def get_processor_list
        Facter::Util::Processor.aix_processor_list
      end
    end

    class HP_UX < Base
      def get_processor_list
        Facter::Util::Processor.hpux_processor_list
      end
    end

    class Darwin < Base
      def initialize
        require "cfpropertylist"
        @system_hardware_data = query_system_profiler
      end

      def get_processor_count
        Facter::Util::POSIX.sysctl("hw.ncpu").to_i
      end

      def get_processor_speed
        @system_hardware_data["current_processor_speed"]
      end

      private

      def query_system_profiler
        output = Facter::Core::Execution.exec("/usr/sbin/system_profiler -xml SPHardwareDataType 2>/dev/null")
        plist  = CFPropertyList::List.new
        plist.load_str(output)
        parsed_xml = CFPropertyList.native_types(plist.value)
        parsed_xml[0]['_items'][0]
      end
    end

    class BSD < Base
      def get_processor_count
        Facter::Util::POSIX.sysctl("hw.ncpu").to_i
      end
    end

    class OpenBSD < BSD
      def get_physical_processor_count
        Facter::Util::POSIX.sysctl("hw.ncpufound").to_i
      end

      def get_processor_speed
        speed = Facter::Util::POSIX.sysctl("hw.cpuspeed").to_i
        if speed < 1000
          "#{speed} MHz"
        else
          speed = speed.to_f / 1000
          "#{(speed * 100).round.to_f / 100.0} GHz"
        end
      end
    end

    class SunOS < Base
      def initialize
        kernelrelease = Facter.value(:kernelrelease)
        @major_version = kernelrelease.split(".")[0].to_i
        @minor_version = kernelrelease.split(".")[1].to_i
      end

      def get_processor_list
        Facter::Util::Processor.enum_kstat
      end

      def get_processor_count
        if @major_version < 5 or (@major_version == 5 and @minor_version < 8)
          if count = count_cpu_with_kstat
            count
          else
            count_cpu_with_psrinfo
          end
        else
          count_cpu_with_psrinfo
        end
      end

      def get_physical_processor_count
        if @major_version > 5 or (@major_version == 5 and @minor_version >= 8)
          if output = Facter::Core::Execution.exec("/usr/sbin/psrinfo -p")
            output.to_i
          end
        else
          count_cpu_with_psrinfo
        end
      end

      private

      def count_cpu_with_kstat
        if output = Facter::Core::Execution.exec("/usr/bin/kstat cpu_info")
          output.scan(/\bcore_id\b\s+\d+/).uniq.length
        else
          nil
        end
      end

      def count_cpu_with_psrinfo
        if output = Facter::Core::Execution.exec("/usr/sbin/psrinfo")
          output.split("\n").length
        else
          nil
        end
      end
    end
  end
end
