# Fact: timezone
#
# Purpose: Return the machine's time zone.
#
# Resolution: Usess Ruby's Time module's `Time.new`.
#
# Caveats:
#

Facter.add("timezone") do
  setcode do
    Time.new.zone
  end
end
