## kernel.rb
## Facts related to the kernel, architecture and related
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

        Facter.add(:kernel) do
            setcode 'uname -s'
        end

        Facter.add(:kernelrelease) do
            setcode 'uname -r'
        end

        Facter.add(:hardwaremodel) do
            setcode 'uname -m'
        end

        Facter.add(:architecture) do
            confine :kernel => :linux
            setcode do
                model = Facter.value(:hardwaremodel)
                case model
                # most linuxen use "x86_64"
                when 'x86_64':
                    Facter.value(:operatingsystem) == "Debian" ? "amd64" : model;
                when /(i[3456]86|pentium)/: "i386"
                else
                    model
                end
            end
        end

      Facter.add(:hardwareisa) do
            setcode 'uname -p', '/bin/sh'
            confine :operatingsystem => %w{Solaris Linux Fedora RedHat CentOS SuSE Debian Gentoo FreeBSD OpenBSD NetBSD}
        end
