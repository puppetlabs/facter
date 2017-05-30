#
# bonding.rb
#
# This fact provides a list of all available bonding interfaces that are
# currently present in the system including details about their current
# configuration in terms of per-interface status, current primary and
# active slave as well as a list of slaves interfaces attached ...
#

require 'thread'
require 'facter'

if Facter.value(:kernel) == 'Linux'
  mutex = Mutex.new

  # We capture per-bonding interface configuration here ...
  configuration = Hash.new { |k,v| k[v] = {} }

  #
  # Modern Linux kernels provide entries under "/proc/net/bonding" directory
  # in the following format.  An example of "/proc/net/bonding/bond0":
  #
  #   Ethernet Channel Bonding Driver: v3.5.0 (November 4, 2008)
  #
  #   Bonding Mode: fault-tolerance (active-backup)
  #   Primary Slave: None
  #   Currently Active Slave: eth0
  #   MII Status: up
  #   MII Polling Interval (ms): 100
  #   Up Delay (ms): 200
  #   Down Delay (ms): 200
  #
  #   Slave Interface: eth0
  #   MII Status: up
  #   Link Failure Count: 0
  #   Permanent HW addr: 68:b5:99:c0:56:74
  #
  #   Slave Interface: eth1
  #   MII Status: up
  #   Link Failure Count: 0
  #   Permanent HW addr: 00:25:b3:02:b3:18
  #

  #
  #  As per the "drivers/net/bonding/bond_main.c" in Linux kernel 2.6 and 3.0:
  #
  #  MODULE_PARM_DESC(mode, "Mode of operation; 0 for balance-rr, "
  #                         "1 for active-backup, 2 for balance-xor, "
  #                         "3 for broadcast, 4 for 802.3ad, 5 for balance-tlb, "
  #                         "6 for balance-alb");
  #
  #  static const char *names[] = {
  #   [BOND_MODE_ROUNDROBIN] = "load balancing (round-robin)",
  #   [BOND_MODE_ACTIVEBACKUP] = "fault-tolerance (active-backup)",
  #   [BOND_MODE_XOR] = "load balancing (xor)",
  #   [BOND_MODE_BROADCAST] = "fault-tolerance (broadcast)",
  #   [BOND_MODE_8023AD] = "IEEE 802.3ad Dynamic link aggregation",
  #   [BOND_MODE_TLB] = "transmit load balancing",
  #   [BOND_MODE_ALB] = "adaptive load balancing",
  #  };
  #
  BONDING_MODE = {
    '^IEEE\s802\.3'                        => '802.3ad',
    '^[aA]daptive\s[lL]oad'                => 'balance-alb',
    '^[tT]transmit\s[lL]oad'               => 'balance-tlb',
    '^[lL]oad\s.+\s\([xX]or\)'             => 'balance-xor',
    '^[lL]oad\s.+\s\([rR]ound.+\)'         => 'balance-rr',
    '^[fF]ault(\s|\-).+\s\([aA]ctive.+\)'  => 'active-backup',
    '^[fF]ault(\s|\-).+\s\([bB]roadcast\)' => 'broadcast',
  }.freeze unless defined? BONDING_MODE

  # Check whether there is anything to do at all ...
  if File.exists?('/proc/net/bonding')
    # We search inside the "/proc/net/bonding" directory for all bonding
    # interfaces and then process each one of them as a separate case ...
    Array(Dir['/proc/net/bonding/*']).each do |interface|
      # We store name of the slave interfaces on the side ...
      slaves = []

      #
      # We utilise rely on "cat" for reading values from entries under "/proc".
      # This is due to some problems with IO#read in Ruby and reading content of
      # the "proc" file system that was reported more than once in the past ...
      #
      Facter::Util::Resolution.exec("cat #{interface} 2> /dev/null").each_line do |line|
        # Remove bloat ...
        line.strip!

        # Skip new and empty lines ...
        next if line.match(/^(\r\n|\n|\s*)$|^$/)

        # Strip surplus path from the name ...
        interface = File.basename(interface)

        # Process configuration line by line ...
        case line
        when /Bonding Mode:\s/
          # Take the value only  ...
          value = line.split(':')[1].strip

          #
          # We assume that we might not know the mode for some reason and if
          # so, then we simply indicate that ...  This is to keep consistency
          # with rest of the output from this particular fact ...
          #
          mode = 'unknown'

          # Look-up against known operating modes ...  Fist match wins ...
          BONDING_MODE.each do |k,v|
            if value.match(k)
              mode = v
              break
            end
          end

          mutex.synchronize do
            configuration[interface].update(:mode => mode)
          end
        when /Primary Slave:\s/
          # Take the value only  ...
          value = line.split(':')[1].strip

          mutex.synchronize do
            configuration[interface].update(:primary_slave => value)
          end
        when /Currently Active Slave:\s/
          # Take the value only ...
          value = line.split(':')[1].strip

          mutex.synchronize do
            configuration[interface].update(:active_slave => value)
          end
        when /MII Status:\s/
          # Take the value only ...
          value = line.split(':')[1].strip

          mutex.synchronize do
            configuration[interface].update(:status => value)
          end
        when /Slave Interface:\s/
          # Take the value only ...
          value = line.split(':')[1].strip

          mutex.synchronize do
            slaves << value
          end
        else
          # Skip irrelevant entries ...
          next
        end
      end

      #
      # No slaves?  Then set to "none" otherwise ensure proper sorting order
      # by the interface name ...  This is to ensure consistency between active
      # and inactive bonding interface ...  In other words if the bonding
      # interface is "down" we still set relevant fact about its slaves ...
      #
      slaves = slaves.empty? ? 'none' : slaves.sort_by { |i| i.scan(/\d+/).shift.to_i }

      mutex.synchronize do
        configuration[interface].update(:slaves => slaves)
      end
    end

    # To ensure proper sorting order by the interface name ...
    interfaces = configuration.keys.sort_by { |i| i.scan(/\d+/).shift.to_i }

    Facter.add('bonding_interfaces') do
      confine :kernel => :linux
      setcode { Facter::Util::Resolution.exec("cat /sys/class/net/bonding_masters").split.join(",") }
    end

    # Process per-interface configuration and add fact about it ...
    interfaces.each do |interface|
      configuration[interface].each do |k,v|
        # Check whether we deal with a list of slaves or not ...
        value = v.is_a?(Array) ? v.join(',') : v

        # Make everything lower-case for consistency sake ...
        value.tr!('A-Z', 'a-z')

        # Add fact relevant to a particular bonding interface ...
        Facter.add("bonding_#{interface}_#{k.to_s}") do
          confine :kernel => :linux
          setcode { value }
        end
      end
    end
  end
end

# vim: set ts=2 sw=2 et :
# encoding: utf-8
