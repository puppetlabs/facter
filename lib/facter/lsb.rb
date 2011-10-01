# Fact: lsb
#
# Purpose: Return Linux Standard Base information for the host.
#
# Resolution:
#   Uses the lsb_release system command and parses the output with a series of
#   regular expressions.
#
# Caveats:
#   Only works on Linux (and the kfreebsd derivative) systems.
#   Requires the lsb_release program, which may not be installed by default.
#   Also is as only as accurate as that program outputs.

## lsb.rb
## Facts related to Linux Standard Base (LSB)

{  "LSBRelease"         => %r{^LSB Version:\t(.*)$},
   "LSBDistId"          => %r{^Distributor ID:\t(.*)$},
   "LSBDistRelease"     => %r{^Release:\t(.*)$},
   "LSBDistDescription" => %r{^Description:\t(.*)$},
   "LSBDistCodeName"    => %r{^Codename:\t(.*)$}
}.each do |fact, pattern|
  Facter.add(fact) do
    confine :kernel => [ :linux, :"gnu/kfreebsd" ]
    setcode do
      unless defined?(lsbdata) and defined?(lsbtime) and (Time.now.to_i - lsbtime.to_i < 5)
        type = nil
        lsbtime = Time.now
        lsbdata = Facter::Util::Resolution.exec('lsb_release -a 2>/dev/null')
      end

      if pattern.match(lsbdata)
        $1
      else
        nil
      end
    end
  end
end
