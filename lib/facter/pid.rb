# Fact: pid
#
# Purpose: Internal fact for what to use to list the process id. 
#
# Resolution:
#   Assumes "Process.pid" for all operating systems 
#
# Caveats:
#

Facter.add("pid") do
  setcode {Process.pid}
end
