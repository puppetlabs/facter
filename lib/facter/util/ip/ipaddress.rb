module Facter::Util::IP
  module Ipaddress

  MAP = {
    :ipv4 => {
      :linux => {
        :ip => {
          :regex => '([0-9]+\.[0-9]+\.[0-9]+\.[0-9]+)',
          :exec  => '/sbin/ip addr show',
          :token => 'inet ',
          :ignore => '^127\.|^0\.0\.0\.0',
        },
        :ifconfig => {
          :regex  => '([0-9]+\.[0-9]+\.[0-9]+\.[0-9]+)',
          :exec   => '/sbin/ifconfig',
          :token  => 'inet addr: ',
          :ignore => '^127\.|^0\.0\.0\.0',
        },
      },
      :bsdlike => {
        :aliases  => [:openbsd, :netbsd, :freebsd, :darwin, :"gnu/kfreebsd", :dragonfly],
        :ifconfig => {
          :regex  => '([0-9]+\.[0-9]+\.[0-9]+\.[0-9]+)',
          :exec  => '/sbin/ifconfig',
          :token => 'inet addr: ',
          :ignore => '^127\.|^0\.0\.0\.0',
        },
      },
      :sunos => {
        :ifconfig => {
          :regex  => '([0-9]+\.[0-9]+\.[0-9]+\.[0-9]+)',
          :exec  => '/usr/sbin/ifconfig',
          :token => 'inet ',
          :ignore => '^127\.|^0\.0\.0\.0',
        },
      },
      :"hp-ux" => {
        :ifconfig => {
          :regex  => '([0-9]+\.[0-9]+\.[0-9]+\.[0-9]+)',
          :exec  => '/usr/sbin/ifconfig',
          :token => 'inet ',
          :ignore => '^127\.',
        },
      },
      :aix => {
        :ifconfig => {
          :regex  => '([0-9]+\.[0-9]+\.[0-9]+\.[0-9]+)',
          :exec  => '/sbin/ifconfig -a',
          :token => 'inet ',
          :ignore => '^127\.',
        },
      },
      :windows => {
        :netsh => {
          :regex  => '([0-9]+\.[0-9]+\.[0-9]+\.[0-9]+)',
          :exec  => "#{ENV['SYSTEMROOT']}/system32/netsh.exe interface ip show interface",
          :token => 'IP Address:\s+',
          :ignore => '^127\.',
        },
      },
    },
    :ipv6 => {
      :linux => {
        :ip => {
          :regex => '((?![fe80|::1])(?>[0-9,a-f,A-F]*\:{1,2})+[0-9,a-f,A-F]{0,4})',
          :exec  => '/sbin/ip addr show',
          :token => 'inet6 ',
          :ignore => '^fe80::',
        },
        :ifconfig => {
          :regex  => '((?![fe80|::1])(?>[0-9,a-f,A-F]*\:{1,2})+[0-9,a-f,A-F]{0,4})',
          :exec   => '/sbin/ifconfig',
          :token  => 'inet6 addr: ',
          :ignore => '^127\.|^0\.0\.0\.0',
          :ignore => '^fe80::',
        },
      },
      :bsdlike => {
        :aliases  => [:openbsd, :netbsd, :freebsd, :darwin, :"gnu/kfreebsd", :dragonfly],
        :ifconfig => {
          :regex => '((?![fe80|::1])(?>[0-9,a-f,A-F]*\:{1,2})+[0-9,a-f,A-F]{0,4})',
          :exec  => '/sbin/ifconfig',
          :token => 'inet6 addr: ',
          :ignore => '^fe80::',
        },
      },
      :darwin => {
        :ifconfig => {
          :regex => '((?![fe80|::1])(?>[0-9,a-f,A-F]*\:{1,2})+[0-9,a-f,A-F]{0,4})',
          :exec  => '/sbin/ifconfig',
          :token => 'inet6 ',
          :ignore => '^fe80::',
        },
      },
      :sunos => {
        :ifconfig => {
          :regex => '((?![fe80|::1])(?>[0-9,a-f,A-F]*\:{1,2})+[0-9,a-f,A-F]{0,4})',
          :exec  => '/usr/sbin/ifconfig',
          :token => 'inet6 ',
          :ignore => '^fe80::',
        },
      },
      :"hp-ux" => {
        :ifconfig => {
          :regex => '((?![fe80|::1])(?>[0-9,a-f,A-F]*\:{1,2})+[0-9,a-f,A-F]{0,4})',
          :exec  => '/usr/sbin/ifconfig',
          :token => 'inet6 addr: ',
          :ignore => '^fe80::',
        },
      },
      :aix => {
        :ifconfig => {
          :regex => '((?![fe80|::1])(?>[0-9,a-f,A-F]*\:{1,2})+[0-9,a-f,A-F]{0,4})',
          :exec  => '/sbin/ifconfig -a',
          :token => 'inet6 ',
          :ignore => '^fe80::',
        },
      },
      :windows => {
        :netsh => {
          :regex => '((?![fe80|::1])(?>[0-9,a-f,A-F]*\:{1,2})+[0-9,a-f,A-F]{0,4})',
          :exec  => "#{ENV['SYSTEMROOT']}/system32/netsh.exe interface ipv6 show interface",
          :token => 'Address\s+',
          :ignore => '^fe80::',
        },
      },
    },
  }

  def self.get(interface, ip_version='ipv4', ignore=nil)
    return nil unless Facter::Util::IP.supported_platforms(MAP[ip_version.downcase.to_sym])
    return nil unless ip_version == 'ipv4' || ip_version == 'ipv6'
    ipaddress = nil
    map = Facter::Util::IP.find_submap(MAP[ip_version.downcase.to_sym])

    # This checks each exec in turn until one is found and then uses that
    # method for the rest of the matches.
    method = Facter::Util::IP.find_method(map)
    exec   = map[method.to_sym][:exec]
    token  = map[method.to_sym][:token]
    regex  = map[method.to_sym][:regex]
    if ignore.nil?
      ignore = map[method.to_sym][:ignore]
    end

    command = "#{exec}"
    command << " #{interface}" unless interface.nil?

    output = Facter::Util::Resolution.exec(command)
    return [] if output.nil?
    ipaddress = Facter::Util::IP.find_token(output, token, regex, ignore)
  end

  end
end
