module Facter::Util::NetStat
  COLUMN_MAP = {
    :bsd     => {
      :aliases => [:sunos, :freebsd, :netbsd, :darwin],
      :dest    => 0,
      :gw      => 1,
      :iface   => 5
    },
    :linux   => {
      :dest   => 0,
      :gw     => 1,
      :iface  => 7
    },
    :openbsd => {
      :dest   => 0,
      :gw     => 1,
      :iface  => 6
    }
  }

  def self.supported_platforms
    COLUMN_MAP.inject([]) do |result, tmp|
      key, map = tmp
      if map[:aliases]
        result += map[:aliases]
      else
        result << key
      end
      result
    end
  end

  def self.get_ipv4_output
    output = ""
    case Facter.value(:kernel)
    when 'SunOS', 'FreeBSD', 'NetBSD', 'OpenBSD'
      output = %x{/usr/bin/netstat -rn -f inet}
    when 'Darwin' 
      output = %x{/usr/sbin/netstat -rn -f inet}
    when 'Linux'
      output = %x{/bin/netstat -rn -A inet}
    end
    output
  end

  def self.get_route_value(route, label)
    tmp1 = []

    kernel = Facter.value(:kernel).downcase.to_sym

    # If it's not directly in the map or aliased in the map, then we don't know how to deal with it.
    unless map = COLUMN_MAP[kernel] || COLUMN_MAP.values.find { |tmp| tmp[:aliases] and tmp[:aliases].include?(kernel) }
      return nil
    end

    c1 = map[:dest]
    c2 = map[label.to_sym]

    get_ipv4_output.to_a.collect { |s| s.split}.each { |a|
      if a[c1] == route
        tmp1 << a[c2]
      end
    }

    if tmp1
      return tmp1.shift
    end
  end
end
