# Fact: timezone
#
# Purpose: 
#   Return the machine's time zone.
#
# Resolution: 
#   Uses's Ruby's Time module's Time.new call.
#
## timezone.rb
#

Facter.add("timezone") do
  setcode do
    Time.new.zone
  end
end
