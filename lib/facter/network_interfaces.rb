Facter.add("network_interfaces") do
  confine :kernel => :darwin

  setcode do
    ifconfig = Facter::Util::Resolution.exec("ifconfig -a")

    interfaces = []

    iface = {}
    ifconfig.each_line do |line|
      case line
      when /^(.+):\s+flags=\d+<(.*)>\s+mtu\s+(\d+)\s*$/
        # Store the old interface if there is one in the interfaces array
        interfaces << iface if iface["name"]

        # And now reset, as everything is assigned to the new interface
        iface = {}

        iface["name"] = $1
        iface["mtu"] = $3 if $3
        iface["flags"] = $2.split(",")
      when /^\s+options=\d+<(.*)>\s*$/
        raise Exception("Parse error - no interface") unless iface["name"]
        iface["options"] = $1.split(",")
      when /^\s+inet6\s+(.+)\s+prefixlen\s+(\d+)(\s+scopeid\s+(.+))\s*$/
        raise Exception("Parse error - no interface") unless iface["name"]
        inet6 = {
          "address"   => $1,
          "prefixlen" => $2,
          "scopeid"   => $3,
        }
        iface["inet6"] ||= []
        iface["inet6"] << inet6
      when /^\s+inet\s+(.+)\s+netmask\s+(.+)\s*$/
        raise Exception("Parse error - no interface") unless iface["name"]
        inet4 = {
          "address" => $1,
          "netmask" => $2,
        }
        iface["inet4"] ||= []
        iface["inet4"] << inet4
      when /^\s+ether\s+(.+)\s*$/
        raise Exception("Parse error - no interface") unless iface["name"]
        iface["ether"] = $1
      when /^\s+media:\s+(.+)\s+(.+)\s*$/
        raise Exception("Parse error - no interface") unless iface["name"]
        iface["media"] ||= {}
        iface["media"]["setting"] = $1
        iface["media"]["real"] = $2
      when /^\s+status:\s+(.+)\s*$/
        raise Exception("Parse error - no interface") unless iface["name"]
        iface["status"] = $1
      end
    end

    interfaces
  end
end
