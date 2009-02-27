# Changelog:
# Original facts - Tim Dysinger
# Updated and added can_connect? function - KurtBe

require 'open-uri'
require 'timeout'

def can_connect?(ip,port,wait_sec=2)
 Timeout::timeout(wait_sec) {open(ip, port)}
 return true
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

if can_connect?("169.254.169.254","80")
  metadata
end

