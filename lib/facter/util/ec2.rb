require 'timeout'
require 'open-uri'

# Provide a set of utility static methods that help with resolving the EC2
# fact.
module Facter::Util::EC2
  class << self
    # Test if we can connect to the EC2 api. Return true if able to connect.
    # On failure this function fails silently and returns false.
    #
    # The +wait_sec+ parameter provides you with an adjustable timeout.
    #
    def can_connect?(wait_sec=2)
      url = "http://169.254.169.254:80/"
      Timeout::timeout(wait_sec) {open(url)}
      return true
    rescue
      return false
    end

    # Test if this host has a mac address used by Eucalyptus clouds, which
    # normally is +d0:0d+.
    def has_euca_mac?
      !!(Facter.value(:macaddress) =~ %r{^[dD]0:0[dD]:})
    end

    # Test if this host has a mac address used by OpenStack, which
    # normally starts with FA:16:3E (older versions of OpenStack
    # may generate mac addresses starting with 02:16:3E)
    def has_openstack_mac?
      !!(Facter.value(:macaddress) =~ %r{^(02|[fF][aA]):16:3[eE]})
    end

    # Test to see if the EC2 flag file is present
    def has_flag_file?
      if Facter::Util::Config.is_windows?
        FileTest.exist?("#{Facter::Util::Config.windows_data_dir}\\facter_ec2")
      else
        FileTest.exists?("/etc/facter_ec2")
      end
    end

    # Test if the host has an arp entry in its cache that matches the EC2 arp,
    # which is normally +fe:ff:ff:ff:ff:ff+.
    def has_ec2_arp?
      kernel = Facter.value(:kernel)

      mac_address_re = case kernel
                       when /Windows/i
                         /fe-ff-ff-ff-ff-ff/i
                       else
                         /fe:ff:ff:ff:ff:ff/i
                       end

      arp_command = case kernel
                    when /Windows/i, /SunOS/i
                      "arp -a"
                    else
                      "arp -an"
                    end

      if arp_table = Facter::Util::Resolution.exec(arp_command)
        return true if arp_table.match(mac_address_re)
      end
      return false
    end
  end
end
