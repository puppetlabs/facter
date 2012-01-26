# Fact: zonename
#
# Purpose: 
#    Return the machine's current zonename
#
# Resolution: 
#    Uses's the commandline '/usr/bin/zonename'
#
# Caveats: 
#    Only for Solaris operating system 10 and greater
#                                                                                                                   

require 'facter'

Facter.add('zonename') do
  confine :kernel => :sunos
  setcode('zonename')
end
