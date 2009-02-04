Facter.add(:architecture) do
    confine :kernel => :linux
    setcode do
        model = Facter.value(:hardwaremodel)
        case model
        # most linuxen use "x86_64"
        when 'x86_64'
            Facter.value(:operatingsystem) == "Debian" ? "amd64" : model;
        when /(i[3456]86|pentium)/; "i386"
        else
            model
        end
    end
end
