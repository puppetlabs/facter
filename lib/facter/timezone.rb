# Fact: timezone
#
# Purpose: Return the machine's time zone.
#
# Resolution: Uses Ruby's Time module.
#
# Caveats:
#

Facter.add("timezone") do
  setcode do
    Time.new.zone
  end
end
