# A module to gather running Xen Domains
#
module Facter::Util::Xendomains
  def self.get_domains
    xen_commands = ['/usr/sbin/xl', '/usr/sbin/xm']
    command = xen_commands.find { |cmd| Facter::Util::Resolution.which(cmd) }
    if command
                        if xm_list = Facter::Util::Resolution.exec("#{command} list 2>/dev/null")
                                domains = xm_list.split("\n").reject { |line| line =~ /^(Name|Domain-0)/ }
                                domains.map { |line| line.split(/\s/)[0] }.join(',')
                        end
                end
  end
end

