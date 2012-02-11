require 'facter/util/ec2'
require 'open-uri'

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
    value = open("http://169.254.169.254/2008-02-01/user-data/").read.split
    Facter.add(:ec2_userdata) { setcode { value } }
  rescue OpenURI::HTTPError
  end
end

if (Facter::Util::EC2.has_euca_mac? || Facter::Util::EC2.has_openstack_mac? ||
    Facter::Util::EC2.has_ec2_arp?) && Facter::Util::EC2.can_connect?

  metadata
  userdata
else
  Facter.debug "Not an EC2 host"
end
