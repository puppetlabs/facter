# Original fact Tim Dysinger
# Additional work from KurtBe
# Additional work for Paul Nasrat
# Additional work modelled on Ohai EC2 fact
# Remove depedency on arp fact by Pieter Lexis

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
      symbol = "ec2_#{key.gsub(/\-|\//, '_')}".to_sym
      Facter.add(symbol) { setcode { value.join(',') } }
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

# Is the macaddress a eucalyptus macaddress?
def has_euca_mac?
  !!(Facter.value(:macaddress) =~ %r{^[dD]0:0[dD]:})
end

# Is there an entry in the arp table for fe:ff:ff:ff:ff:ff,
# this is a red flag for being on amazon
def has_ec2_arp?
  arp_table = Facter::Util::Resolution.exec('arp -an')
  is_amazon_arp = false
  if not arp_table.nil?
    arp_table.each_line do |line|
      is_amazon_arp = true if line.include?('fe:ff:ff:ff:ff:ff')
      break
    end
  end
  is_amazon_arp
end

if has_ec2_arp?
  Facter.add(:is_ec2) { setcode { "true" } }
elsif has_euca_mac?
  Facter.add(:is_euca) { setcode { "true" } }
else
  Facter.add(:is_ec2) { setcode { "false" } }
  Facter.add(:is_euca) { setcode { "false" } }
end

if (has_euca_mac? || has_ec2_arp?) && can_connect?
  metadata
  userdata
else
  Facter.debug "Not an EC2 or Eucalyptus host"
end
