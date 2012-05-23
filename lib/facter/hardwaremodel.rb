# Fact: hardwaremodel
#
# Purpose:
#   Returns the hardware model of the system.
#
# Resolution:
#   Uses purely "uname -m" on all platforms other than AIX and Windows.
#   On AIX uses the parsed "modelname" output of "lsattr -El sys0 -a modelname".
#   On Windows uses the 'host_cpu' pulled out of Ruby's config.
#
# Caveats:
#

Facter.add(:hardwaremodel) do
  setcode 'uname -m'
end

Facter.add(:hardwaremodel) do
  confine :operatingsystem => :aix
  setcode do
    model = Facter::Util::Resolution.exec('lsattr -El sys0 -a modelname')
    if model =~ /modelname\s(\S+)\s/
      $1
    end
  end
end

Facter.add(:hardwaremodel) do
  confine :operatingsystem => :windows
  setcode do
    # http://source.winehq.org/source/include/winnt.h#L568
    # http://msdn.microsoft.com/en-us/library/windows/desktop/aa394373(v=vs.85).aspx
    # http://msdn.microsoft.com/en-us/library/windows/desktop/windows.system.processorarchitecture.aspx
    require 'facter/util/wmi'
    model = ""
    Facter::Util::WMI.execquery("select Architecture, Level from Win32_Processor").each do |cpu|
      model =
        case cpu.Architecture
        when 11: 'neutral'        # PROCESSOR_ARCHITECTURE_NEUTRAL
        when 10: 'i686'           # PROCESSOR_ARCHITECTURE_IA32_ON_WIN64
        when 9: 'x64'             # PROCESSOR_ARCHITECTURE_AMD64
        when 8: 'msil'            # PROCESSOR_ARCHITECTURE_MSIL
        when 7: 'alpha64'         # PROCESSOR_ARCHITECTURE_ALPHA64
        when 6: 'ia64'            # PROCESSOR_ARCHITECTURE_IA64
        when 5: 'arm'             # PROCESSOR_ARCHITECTURE_ARM
        when 4: 'shx'             # PROCESSOR_ARCHITECTURE_SHX
        when 3: 'powerpc'         # PROCESSOR_ARCHITECTURE_PPC
        when 2: 'alpha'           # PROCESSOR_ARCHITECTURE_ALPHA
        when 1: 'mips'            # PROCESSOR_ARCHITECTURE_MIPS
        when 0: "i#{cpu.Level}86" # PROCESSOR_ARCHITECTURE_INTEL
        else 'unknown'            # PROCESSOR_ARCHITECTURE_UNKNOWN
        end
      break
    end

    model
  end
end
