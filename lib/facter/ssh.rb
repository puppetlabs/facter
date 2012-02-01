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
  {"SSHDSAKey" => { :file => "ssh_host_dsa_key.pub", :sshfprrtype => 2 } , "SSHRSAKey" => { :file => "ssh_host_rsa_key.pub", :sshfprrtype => 1 }, "SSHECDSAKey" => { :file => "ssh_host_ecdsa_key.pub", :sshfprrtype => 3 } }.each do |name,key|
    Facter.add(name) do
      setcode do
        value = nil
        filepath = File.join(dir,key[:file])
        if FileTest.file?(filepath)
          begin
            value = File.read(filepath).chomp.split(/\s+/)[1]
          rescue
            value = nil
          end
        end
        value
      end # end of proc
    end # end of add
    Facter.add('SSHFP_' + name[3..-4]) do
      setcode do
        ssh = Facter.fact(name).value
        value = nil
        if ssh && key[:sshfprrtype]
          begin
            require 'digest/sha1'
            require 'base64'
            digest = Base64.decode64(ssh)
            value = 'SSHFP ' + key[:sshfprrtype].to_s + ' 1 ' + Digest::SHA1.hexdigest(digest)
            begin
              require 'digest/sha2'
              value += "\nSSHFP " + key[:sshfprrtype].to_s + ' 2 ' + Digest::SHA256.hexdigest(digest)
            rescue
            end
          rescue
            value = nil
          end
        end # end of sshfp if
        value
      end # end of sshfp proc
    end # end of sshfp add
  end # end of hash each
end # end of dir each
