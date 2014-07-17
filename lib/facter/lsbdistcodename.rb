# Fact: lsbdistcodename
#
# Purpose: Return Linux Standard Base information for the host.
#
# Resolution:
#   Uses the lsbdistcodename key of the os structured fact, which 
#   itself uses the `lsb_release` system command.
#
# Caveats:
#   Only works on Linux (and the kfreebsd derivative) systems.
#   Requires the `lsb_release` program, which may not be installed by default.
#   Also is as only as accurate as that program outputs.

Facter.add(:lsbdistcodename) do
  confine do
    !Facter.value(:os)["lsb"].nil?
  end

  setcode { Facter.value("os")["lsb"]["distcodename"] }
end
