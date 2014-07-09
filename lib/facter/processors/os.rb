# Processor OS classes
#

require 'facter/processors/util'
require 'facter/util/posix'
require 'facter/util/wmi'

module Facter
  module Processor

    def self.implementation(kernel = Facter::Processor::Util.kernel_fact_value)
      case kernel
      when "Linux"
        Facter::Processor::Linux.new
      when "gnu/kfreebsd"
        Facter::Processor::GNU.new
      when "Darwin"
        Facter::Processor::Darwin.new
      when "aix"
        Facter::Processor::AIX.new
      when "hp-ux"
        Facter::Processor::HP_UX.new
      when "DragonFly", "FreeBSD"
        Facter::Processor::BSD.new
      when "OpenBSD"
        Facter::Processor::OpenBSD.new
      when "SunOS"
        Facter::Processor::SunOS.new
      when "windows"
        Facter::Processor::Windows.new
      end
    end

    class Base
      def get_processor_list
        Facter::Processor::Util.enum_cpuinfo
      end

      def get_processor_count
        get_processor_list.length.to_s
      end

      def get_processor_model
        nil
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
          processor_list.length.to_s
        else
          count_cpu_from_sysfs.to_s
        end
      end

      def count_cpu_from_sysfs
        sysfs_cpu_directory = '/sys/devices/system/cpu'
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

      def count_physical_cpu_from_sysfs
        sysfs_cpu_directory = '/sys/devices/system/cpu'
        if File.exists?(sysfs_cpu_directory)
          lookup_pattern = "#{sysfs_cpu_directory}" + "/cpu*/topology/physical_package_id"
          Dir.glob(lookup_pattern).collect { |f| Facter::Core::Execution.exec("cat #{f}")}.uniq.size.to_s
        else
          nil
        end
      end

      def count_physical_cpu_from_cpuinfo
        str = Facter::Core::Execution.exec("grep 'physical.\+:' /proc/cpuinfo")
        str.scan(/\d+/).uniq.size.to_s if str
      end
    end

    class Windows < Base
      def get_processor_list
        Facter::Processor::Util.windows_processor_list
      end

      def get_physical_processor_count
         Facter::Util::WMI.execquery("select Name from Win32_Processor").Count.to_s
      end
    end

    class AIX < Base
      def get_processor_list
        Facter::Processor::Util.aix_processor_list
      end
    end

    class HP_UX < Base
      def get_processor_list
        Facter::Processor::Util.hpux_processor_list
      end
    end

    class Darwin < Base
      def initialize
        require "cfpropertylist"
        @system_hardware_data = query_system_profiler
      end

      def get_processor_count
        Facter::Util::POSIX.sysctl("hw.ncpu")
      end

      def get_physical_processor_count
        @system_hardware_data["number_processors"].to_s
      end

      def get_processor_speed
        @system_hardware_data["current_processor_speed"].to_s
      end

      def query_system_profiler
        output = Facter::Core::Execution.exec("/usr/sbin/system_profiler -xml SPHardwareDataType")
        plist  = CFPropertyList::List.new
        plist.load_str(output)
        parsed_xml = CFPropertyList.native_types(plist.value)
        parsed_xml[0]['_items'][0]
      end
    end

    class BSD < Base
      def get_processor_count
        Facter::Util::POSIX.sysctl("hw.ncpu")
      end

      def get_processor_model
        Facter::Util::POSIX.sysctl("hw.model")
      end
    end

    class OpenBSD < BSD
      def get_physical_processor_count
        Facter::Util::POSIX.sysctl("hw.ncpufound")
      end
    end

    class SunOS < Base
      def initialize
        kernelrelease = Facter.value(:kernelrelease)
        @major_version = kernelrelease.split(".")[0].to_i
        @minor_version = kernelrelease.split(".")[1].to_i
      end

      def get_processor_list
        Facter::Processor::Util.enum_kstat
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
          Facter::Core::Execution.exec("/usr/sbin/psrinfo -p")
        else
          count_cpu_with_psrinfo
        end
      end

      def count_cpu_with_kstat
        if output = Facter::Core::Execution.exec("/usr/bin/kstat cpu_info")
          output.scan(/\bcore_id\b\s+\d+/).uniq.length
        else
          nil
        end
      end

      def count_cpu_with_psrinfo
        if output = Facter::Core::Execution.exec("/usr/sbin/psrinfo")
          output.split("\n").length.to_s
        else
          nil
        end
      end
    end
  end
end
