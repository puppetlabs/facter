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
      Facter.warnonce("#{self}.#{__method__} is deprecated; see the Facter::EC2 classes instead")
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
      Facter.warnonce("#{self}.#{__method__} is deprecated; see the Facter::EC2 classes instead")
      !!(Facter.value(:macaddress) =~ %r{^[dD]0:0[dD]:})
    end

    # Test if this host has a mac address used by OpenStack, which
    # normally starts with FA:16:3E (older versions of OpenStack
    # may generate mac addresses starting with 02:16:3E)
    def has_openstack_mac?
      Facter.warnonce("#{self}.#{__method__} is deprecated; see the Facter::EC2 classes instead")
      !!(Facter.value(:macaddress) =~ %r{^(02|[fF][aA]):16:3[eE]})
    end

    # Test if the host has an arp entry in its cache that matches the EC2 arp,
    # which is normally +fe:ff:ff:ff:ff:ff+.
    def has_ec2_arp?
      Facter.warnonce("#{self}.#{__method__} is deprecated; see the Facter::EC2 classes instead")
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

      if arp_table = Facter::Core::Execution.exec(arp_command)
        return true if arp_table.match(mac_address_re)
      end
      return false
    end
  end

  ##
  # userdata returns a single string containing the body of the response of the
  # GET request for the URI http://169.254.169.254/latest/user-data/  If the
  # metadata server responds with a 404 Not Found error code then this method
  # retuns `nil`.
  #
  # @param version [String] containing the API version for the request.
  # Defaults to "latest" and other examples are documented at
  # http://aws.amazon.com/archives/Amazon%20EC2
  #
  # @api public
  #
  # @return [String] containing the response body or `nil`
  def self.userdata(version="latest")
    Facter.warnonce("#{self}.#{__method__} is deprecated; see the Facter::EC2 classes instead")
    uri = "http://169.254.169.254/#{version}/user-data/"
    begin
      read_uri(uri)
    rescue OpenURI::HTTPError => detail
      case detail.message
      when /404 Not Found/i
        Facter.debug "No user-data present at #{uri}: server responded with #{detail.message}"
        return nil
      else
        raise detail
      end
    end
  end

  ##
  # read_uri provides a seam method to easily test the HTTP client
  # functionality of a HTTP based metadata server.
  #
  # @api private
  #
  # @return [String] containing the body of the response
  def self.read_uri(uri)
    open(uri).read
  end
  private_class_method :read_uri
end
