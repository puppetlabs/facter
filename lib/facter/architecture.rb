# Fact: architecture
#
# Purpose:
#   Return the CPU hardware architecture.
#
# Resolution:
#   On OpenBSD, Linux and Debian's kfreebsd, use the hardwaremodel fact.
#   Gentoo and Debian call "x86_86" "amd64".
#   Gentoo also calls "i386" "x86".
#
# Caveats:
#

Facter.add(:architecture) do
  setcode do
    model = Facter.value(:hardwaremodel)
    case model
      # most linuxen use "x86_64"
    when "x86_64"
      case Facter.value(:operatingsystem)
      when "Debian", "Gentoo", "GNU/kFreeBSD", "Ubuntu", "Proxmox"
        "amd64"
      else
        model
      end
    when /(i[3456]86|pentium)/
      case Facter.value(:operatingsystem)
      when "Gentoo", "windows"
        "x86"
      else
        "i386"
      end
    else
      model
    end
  end
end
