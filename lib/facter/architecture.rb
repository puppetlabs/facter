# Fact: architecture
#
# Purpose:
#   Return the CPU hardware architecture.
#
# Resolution:
#   On non-AIX IBM, OpenBSD, Linux, and Debian's kfreebsd, use the hardwaremodel fact.
#   On AIX get the arch value from `lsattr -El proc0 -a type`.
#   Gentoo and Debian call "x86_86" "amd64".
#   Gentoo also calls "i386" "x86".
#
# Caveats:
#

require 'facter/util/architecture'

Facter.add(:architecture) do
  setcode do
    model = Facter.value(:hardwaremodel)
    case model
      # most linuxen use "x86_64"
    when /IBM*/
      case Facter.value(:operatingsystem)
      when "AIX"
         arch = Facter::Util::Architecture.lsattr
         if (match = arch.match /type\s(\S+)\s/)
           match[1]
         end
      else
        model
      end
    when "x86_64"
      case Facter.value(:operatingsystem)
      when "Debian", "Gentoo", "GNU/kFreeBSD", "Ubuntu"
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
