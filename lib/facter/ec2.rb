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

def check_cache?
  if FileTest.exists?('/tmp/facter_ec2.cache')
    return true
  else
    return false
  end
end

def metadata(id = "")
  meta = {}
  begin
    open("http://169.254.169.254/2008-02-01/meta-data/#{id||=''}").read.
      split("\n").each do |o|
      key = "#{id}#{o.gsub(/\=.*$/, '/')}"
        if key[-1..-1] != '/'
        value = open("http://169.254.169.254/2008-02-01/meta-data/#{key}").read.
          split("\n")
        if value.size > 1
          value = value.join(",")
        end
        symbol = "ec2_#{key.gsub(/\-|\//, '_')}".to_sym
        Facter.add(symbol) { setcode { value } }
        meta[symbol] = value
      else
        metadata(key)
      end
    end
    metadata_write(meta)
  rescue
    if check_cache?
      metadata_cache()
    end
  end
end

def metadata_cache()
  meta = metadata_read()
  meta.each do |symbol,value|
    Facter.add(symbol) { setcode {value} }
  end
end

def metadata_write(meta)
  File.open('/tmp/facter_ec2.cache', "wb") {|f| Marshal.dump(meta, f)}
end

def metadata_read()
  meta = File.open('/tmp/facter_ec2.cache', "rb") {|f| Marshal.load(f)}
  return meta
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
elsif check_cache?
  metadata_cache
else
  Facter.debug "Not an EC2 host"
end
