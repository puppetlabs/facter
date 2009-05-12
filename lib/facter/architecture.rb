Facter.add(:architecture) do
    confine :kernel => :linux
    setcode do
        model = Facter.value(:hardwaremodel)
        case model
        # most linuxen use "x86_64"
        when "x86_64"
            case Facter.value(:operatingsystem)
            when "Debian", "Gentoo"
                "amd64"
            else
                model
            end
        when /(i[3456]86|pentium)/
            case Facter.value(:operatingsystem)
            when "Gentoo"
                "x86"
            else
                "i386"
            end
        else
            model
        end
    end
end
