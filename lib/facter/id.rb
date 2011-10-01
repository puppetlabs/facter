# Fact: id
#
# Purpose: Internal fact used to specity the program to return the currently
# running user id.
#
# Resolution:
#   On all Unixes bar Solaris, just returns "whoami".
#   On Solaris, parses the output of the "id" command to grab the username, as
#   Solaris doesn't have the whoami command.
#
# Caveats:
#

Facter.add(:id) do
  setcode "whoami"
end

Facter.add(:id) do
  confine :kernel => :SunOS
  setcode "/usr/xpg4/bin/id -un"
end
