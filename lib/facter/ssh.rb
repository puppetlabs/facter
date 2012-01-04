# Fact: ssh
#
# Purpose:
#
# Resolution:
#
# Caveats:
#

## ssh.rb
## Facts related to SSH
##

["/etc/ssh","/usr/local/etc/ssh","/etc","/usr/local/etc"].each do |dir|
  {"SSHDSAKey" => "ssh_host_dsa_key.pub", "SSHRSAKey" => "ssh_host_rsa_key.pub", "SSHECDSAKey" => "ssh_host_ecdsa_key.pub"}.each do |name,file|
    Facter.add(name) do
      setcode do
        value = nil
        filepath = File.join(dir,file)
        if FileTest.file?(filepath)
          begin
            File.open(filepath) { |f| value = f.read.chomp.split(/\s+/)[1] }
          rescue
            value = nil
          end
        end
        value
      end # end of proc
    end # end of add
  end # end of hash each
end # end of dir each
