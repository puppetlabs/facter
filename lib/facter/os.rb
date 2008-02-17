## os.rb
## Facts related to operating systems and releases
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

        Facter.add(:operatingsystem) do
            confine :kernel => :sunos
            setcode do "Solaris" end
        end

        Facter.add(:operatingsystem) do
            confine :kernel => :linux
            setcode do
                if Facter.value(:lsbdistid) == "Ubuntu"
                   "Ubuntu"
                elsif FileTest.exists?("/etc/debian_version")
                    "Debian"
                elsif FileTest.exists?("/etc/gentoo-release")
                    "Gentoo"
                elsif FileTest.exists?("/etc/fedora-release")
                    "Fedora"
                elsif FileTest.exists?("/etc/mandriva-release")
                    "Mandriva"
                elsif FileTest.exists?("/etc/mandrake-release")
                    "Mandrake"
                elsif FileTest.exists?("/etc/redhat-release")
                    txt = File.read("/etc/redhat-release")
                    if txt =~ /centos/i
                        "CentOS"
                    else
                        "RedHat"
                    end
                elsif FileTest.exists?("/etc/SuSE-release")
                    "SuSE"
                end
            end
        end

        Facter.add(:operatingsystem) do
            # Default to just returning the kernel as the operating system
            setcode do Facter[:kernel].value end
        end

        Facter.add(:operatingsystemrelease) do
            confine :operatingsystem => :fedora
            setcode do
                File::open("/etc/fedora-release", "r") do |f|
                    line = f.readline.chomp
                    if line =~ /\(Rawhide\)$/
                        "Rawhide"
                    elsif line =~ /release (\d+)/
                        $1
                    end
                end
            end
        end

        Facter.add(:operatingsystemrelease) do
            confine :operatingsystem => %w{RedHat}
            setcode do
                File::open("/etc/redhat-release", "r") do |f|
                    line = f.readline.chomp
                    if line =~ /\(Rawhide\)$/
                        "Rawhide"
                    elsif line =~ /release (\d+)/
                        $1
                    end
                end
            end
        end

        Facter.add(:operatingsystemrelease) do
            confine :operatingsystem => %w{CentOS}
            setcode do
                release = Facter::Resolution.exec('rpm -q centos-release')
                    if release =~ /release-(\d+)/
                        $1
                    end
            end
        end

        Facter.add(:operatingsystemrelease) do
            confine :operatingsystem => %w{Debian}
            setcode do
                release = Facter::Resolution.exec('cat /proc/version')
                    if release =~ /\(Debian (\d+.\d+).\d+-\d+\)/
                        $1
                    end
             end
        end

        Facter.add(:operatingsystemrelease) do
            confine :operatingsystem => %w{Ubuntu}
            setcode do
                release = Facter::Resolution.exec('cat /etc/issue')
                    if release =~ /Ubuntu (\d+.\d+)/
                        $1
                    end
            end
        end

        Facter.add(:operatingsystemrelease) do
            setcode do Facter[:kernelrelease].value end
        end

