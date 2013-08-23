# A module to gather running Xen Domains
#
module Facter::Util::Xendomains
  XEN_COMMANDS = ['/usr/sbin/xl', '/usr/sbin/xm']

  def self.xen_command
    XEN_COMMANDS.find { |cmd| Facter::Util::Resolution.which(cmd) }
  end

  def self.get_domains
    command = self.xen_command
    if command
      if domains_list = Facter::Util::Resolution.exec("#{command} list 2>/dev/null")
        domains = domains_list.split("\n").reject { |line| line =~ /^(Name|Domain-0)/ }
        domains.map { |line| line.split(/\s/)[0] }.join(',')
      end
    end
  end
end
