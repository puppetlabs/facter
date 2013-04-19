if Facter.fact(:kernel).value == "windows"
  require 'facter/util/wmi'

  result = Facter::Util::WMI.connect("winmgmts:{impersonationLevel=impersonate}!//./root/cimv2:win32_operatingsystem=@")

  result.properties_.each do |property|
    Facter.add("wmi_win32_operatingsystem_#{property.name}") do
      confine :kernel => :windows
      setcode do
        property.value
      end
    end
  end
end
