# Fact: xendomains
#
# Purpose: Return the list of Xen domains on the Dom0.
#
# Resolution:
#   On a Xen Dom0 host, return a list of Xen domains using the `util/xendomains`
#   library.
#
# Caveats:
#
require 'facter/util/xendomains'

Facter.add("xendomains") do
  confine :kernel => %w{Linux FreeBSD OpenBSD SunOS}
  confine :virtual => 'xen0'

  setcode do
    Facter::Util::Xendomains.get_domains
  end
end
