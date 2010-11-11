require 'facter/util/xendomains'

Facter.add("xendomains") do
  confine :kernel => %w{Linux FreeBSD OpenBSD SunOS}
  confine :virtual => 'xen0'

  setcode do
    Facter::Util::Xendomains.get_domains
  end
end
