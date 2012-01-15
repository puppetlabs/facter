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
      rescue Timeout::Error
        return false
      rescue
        return false
    end

    # Test if this host has a mac address used by Eucalyptus clouds, which
    # normally is +d0:0d+.
    def has_euca_mac?
      !!(Facter.value(:macaddress) =~ %r{^[dD]0:0[dD]:})
    end

    # Test if the host has an arp entry in its cache that matches the EC2 arp,
    # which is normally +fe:ff:ff:ff:ff:ff+.
    def has_ec2_arp?
      mac_address = "fe:ff:ff:ff:ff:ff"
      if Facter.value(:kernel) == 'windows'
        arp_command = "arp -a"
        mac_address.gsub!(":","-")
      else
        arp_command = "arp -an"
      end

      arp_table = Facter::Util::Resolution.exec(arp_command)
      if not arp_table.nil?
        arp_table.each_line do |line|
          return true if line.include?(mac_address)
        end
      end
      return false
    end
  end
end
