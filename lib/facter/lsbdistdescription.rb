# Fact: lsbdistdescription
#
# Purpose: Return Linux Standard Base information for the host.
#
# Resolution:
#   Uses the `lsb_release` system command.
#
# Caveats:
#   Only works on Linux (and the kfreebsd derivative) systems.
#   Requires the `lsb_release` program, which may not be installed by default.
#   Is only as accurate as the output of `lsb_release`.
#

Facter.add(:lsbdistdescription) do
  confine :kernel => [ :linux, :"gnu/kfreebsd" ]
  confine do
    Facter::Core::Execution.which("lsb_release")
  end

  setcode do
    if output = Facter::Core::Execution.exec('lsb_release -d -s 2>/dev/null')
      # the output may be quoted (at least it is on gentoo)
      output.sub(/^"(.*)"$/,'\1')
    end
  end
end
