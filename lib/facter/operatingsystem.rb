require 'facter/lsb'

Facter.add(:operatingsystem) do
    confine :kernel => :sunos
    setcode do "Solaris" end
end

Facter.add(:operatingsystem) do
    confine :kernel => :linux
    setcode do
        if Facter.value(:lsbdistid) == "Ubuntu"
           "Ubuntu"
        elsif FileTest.exists?("/etc/debian_version")
            "Debian"
        elsif FileTest.exists?("/etc/gentoo-release")
            "Gentoo"
        elsif FileTest.exists?("/etc/fedora-release")
            "Fedora"
        elsif FileTest.exists?("/etc/mandriva-release")
            "Mandriva"
        elsif FileTest.exists?("/etc/mandrake-release")
            "Mandrake"
        elsif FileTest.exists?("/etc/arch-release")
            "Archlinux"
        elsif FileTest.exists?("/etc/enterprise-release")
            if FileTest.exists?("/etc/ovs-release")
                "OVS"
            else
                "OEL"
            end
        elsif FileTest.exists?("/etc/arch-release")
            "Arch"
        elsif FileTest.exists?("/etc/redhat-release")
            txt = File.read("/etc/redhat-release")
            if txt =~ /centos/i
                "CentOS"
            else
                "RedHat"
            end
        elsif FileTest.exists?("/etc/SuSE-release")
            txt = File.read("/etc/SuSE-release")
            if txt =~ /^SUSE LINUX Enterprise Server/i
                "SLES"
            elsif txt =~ /^SUSE LINUX Enterprise Desktop/i
                "SLED"
            elsif txt =~ /^openSUSE/i
                "OpenSuSE"
            else
                "SuSE"
            end
	elsif FileTest.exists?("/etc/slackware-version")
	    "Slackware"
        end
    end
end

Facter.add(:operatingsystem) do
    # Default to just returning the kernel as the operating system
    setcode do Facter[:kernel].value end
end
