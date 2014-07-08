# Fact: id
#
# Purpose: Internal fact used to specity the program to return the currently
# running user ID.
#
# Resolution:
#   On all Unixes but Solaris, just returns the output from `whoami`.
#   On Solaris, parses the output of the `id` command to grab the username,
#   as Solaris doesn't have the `whoami` command.
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
