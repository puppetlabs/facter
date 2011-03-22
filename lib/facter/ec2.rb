# Original fact Tim Dysinger
# Additional work from KurtBe
# Additional work for Paul Nasrat
# Additional work modelled on Ohai EC2 fact

require 'open-uri'
require 'socket'

EC2_ADDR         = "169.254.169.254"
EC2_METADATA_URL = "http://#{EC2_ADDR}/2008-02-01/meta-data"
EC2_USERDATA_URL = "http://#{EC2_ADDR}/2008-02-01/user-data"
EC2_ARP          = "fe:ff:ff:ff:ff:ff"
EC2_EUCA_MAC     = %r{^[dD]0:0[dD]:}

def can_metadata_connect?(addr, port, timeout=2)
  t = Socket.new(Socket::Constants::AF_INET, Socket::Constants::SOCK_STREAM, 0)
  saddr = Socket.pack_sockaddr_in(port, addr)
  connected = false

  begin
    t.connect_nonblock(saddr)
  rescue Errno::EINPROGRESS
    r,w,e = IO::select(nil,[t],nil,timeout)
    if !w.nil?
      connected = true
    else
      begin
        t.connect_nonblock(saddr)
      rescue Errno::EISCONN
        t.close
        connected = true
      rescue SystemCallError
      end
    end
  rescue SystemCallError
  end
  connected
end

def metadata(id = "")
  open("#{EC2_METADATA_URL}/#{id||=''}").read.
    split("\n").each do |o|
    key = "#{id}#{o.gsub(/\=.*$/, '/')}"
    if key[-1..-1] != '/'
      value = open("#{EC2_METADATA_URL}/#{key}").read.
        split("\n")
      value = value.size>1 ? value : value.first
      symbol = "ec2_#{key.gsub(/\-|\//, '_')}".to_sym
      Facter.add(symbol) { setcode { value } }
    else
      metadata(key)
    end
  end
end

def userdata()
  # assumes the only expected error is the 404 if there's no user-data
  begin
     value = OpenURI.open_uri("#{EC2_USERDATA_URL}/").read.split
     Facter.add(:ec2_userdata) { setcode { value } }
  rescue OpenURI::HTTPError
  end
end

def has_euca_mac?
  !!(Facter.value(:macaddress) =~ EC2_EUCA_MAC)
end

def has_ec2_arp?
  !!(Facter.value(:arp) == EC2_ARP)
end

if (has_euca_mac? || has_ec2_arp?) && can_metadata_connect?(EC2_ADDR,80)
  metadata
  userdata
else
  Facter.debug "Not an EC2 host"
end
