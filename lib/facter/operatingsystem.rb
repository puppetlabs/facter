# Fact: operatingsystem
#
# Purpose: Return the name of the operating system.
#
# Resolution:
#   Uses the name key of the os structured fact, which itself
#   operates on the following conditions:
#
#
#   If the kernel is a Linux kernel, check for the existence of a selection of
#   files in `/etc/` to find the specific flavour.
#   On SunOS based kernels, attempt to determine the flavour, otherwise return Solaris.
#   On systems other than Linux, use the kernel fact's value.
#
# Caveats:
#

Facter.add(:operatingsystem) do
  confine do
    !Facter.value("os")["name"].nil?
  end

  setcode { Facter.value("os")["name"] }
end
