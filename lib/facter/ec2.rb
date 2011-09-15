# Original fact Tim Dysinger
# Additional work from KurtBe
# Additional work for Paul Nasrat
# Additional work modelled on Ohai EC2 fact

require 'open-uri'
require 'timeout'

def can_connect?(wait_sec=2)
  url = "http://169.254.169.254:80/"
  Timeout::timeout(wait_sec) {open(url)}
  return true
  rescue Timeout::Error
    return false
  rescue
    return false
end

def metadata(id = "")
  open("http://169.254.169.254/2008-02-01/meta-data/#{id||=''}").read.
    split("\n").each do |o|
    key = "#{id}#{o.gsub(/\=.*$/, '/')}"
    if key[-1..-1] != '/'
      value = open("http://169.254.169.254/2008-02-01/meta-data/#{key}").read.
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
  begin
     value = OpenURI.open_uri("http://169.254.169.254/2008-02-01/user-data/").read.split
     Facter.add(:ec2_userdata) { setcode { value } }
  rescue OpenURI::HTTPError
  end
end

def has_euca_mac?
  !!(Facter.value(:macaddress) =~ %r{^[dD]0:0[dD]:})
end

def has_ec2_arp?
  !!(Facter.value(:arp) == "fe:ff:ff:ff:ff:ff")
end

if (has_euca_mac? || has_ec2_arp?) && can_connect?
  metadata
  userdata
else
  Facter.debug "Not an EC2 host"
end
