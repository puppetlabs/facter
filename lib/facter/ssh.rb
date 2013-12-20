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

{
  'sshdsakey'   => { :file => 'ssh_host_dsa_key.pub',   :sshfprrtype => 2 },
  'sshrsakey'   => { :file => 'ssh_host_rsa_key.pub',   :sshfprrtype => 1 },
  'sshecdsakey' => { :file => 'ssh_host_ecdsa_key.pub', :sshfprrtype => 3 },
}.each do |name,key|
  
  Facter.add(name.to_sym) do
    setcode do
      value = nil
      
      [ "/etc/ssh",
        "/usr/local/etc/ssh",
        "/etc",
        "/usr/local/etc",
        "/etc/opt/ssh",
      ].each do |dir|
      
        filepath = File.join(dir,key[:file])
      
        if FileTest.file?(filepath)
          begin
            value = File.read(filepath).chomp.split(/\s+/)[1]
            break
          rescue
            value = nil
          end
        end
      end
      
      value
    end
  end
  
  Facter.add(('sshfp_' + name[3..-4]).to_sym) do
    setcode do
      ssh = Facter.fact(name.to_sym).value
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
      end
      
      value
    end
    
  end
  
end
