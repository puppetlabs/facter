## ssh.rb
## Facts related to SSH
##
## This program is free software; you can redistribute it and/or
## modify it under the terms of the GNU General Public License
## as published by the Free Software Foundation (version 2 of the License)
## This program is distributed in the hope that it will be useful,
## but WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
## GNU General Public License for more details.
## You should have received a copy of the GNU General Public License
## along with this program; if not, write to the Free Software
## Foundation, Inc., 51 Franklin St, Fifth Floor, Boston MA  02110-1301 USA
##

["/etc/ssh","/usr/local/etc/ssh","/etc","/usr/local/etc"].each do |dir|
    {"SSHDSAKey" => "ssh_host_dsa_key.pub", "SSHRSAKey" => "ssh_host_rsa_key.pub"}.each do |name,file|
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
