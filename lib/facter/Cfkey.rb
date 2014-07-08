# Fact: cfkey
#
# Purpose: Return the public key(s) for CFengine.
#
# Resolution:
#   Tries each file of standard `localhost.pub` and `cfkey.pub` locations,
#   checks if they appear to be a public key, and then join them all together.
#
# Caveats:
#

## Cfkey.rb
## Facts related to cfengine
##

Facter.add(:Cfkey) do
  setcode do
    value = nil
    ["/usr/local/etc/cfkey.pub",
      "/etc/cfkey.pub",
      "/var/cfng/keys/localhost.pub",
      "/var/cfengine/ppkeys/localhost.pub",
      "/var/lib/cfengine/ppkeys/localhost.pub",
      "/var/lib/cfengine2/ppkeys/localhost.pub"
    ].each do |file|
      if FileTest.file?(file)
        File.open(file) { |openfile|
          value = openfile.readlines.reject { |line|
            line =~ /PUBLIC KEY/
          }.collect { |line|
            line.chomp
          }.join("")
        }
      end
      if value
        break
      end
    end

    value
  end
end
