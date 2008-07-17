Facter.add(:kernelrelease) do
    setcode 'uname -r'
end

Facter.add(:kernelrelease, :timeout => 5) do
    confine :kernel => :aix
    setcode 'oslevel -s'
end

Facter.add(:kernelrelease) do
    confine :kernel => %{windows}
    setcode do
        require 'win32ole'
        version = ""
        connection_string = "winmgmts://./root/cimv2"
        wmi = WIN32OLE.connect(connection_string)
        wmi.ExecQuery("SELECT Version from Win32_OperatingSystem").each { |ole|
            version = "#{ole.Version}"
            break
        }
        version
    end
end
