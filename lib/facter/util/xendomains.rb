# A module to gather running Xen Domains
#
module Facter::Util::Xendomains
  def self.get_domains
    if xm_list = Facter::Util::Resolution.exec('/usr/sbin/xm list 2>/dev/null')
      domains = xm_list.split("\n").reject { |line| line =~ /^(Name|Domain-0)/ }
      domains.map { |line| line.split(/\s/)[0] }.join(',')
    end
  end
end
