## process.rb
## Facts related to ps and processes
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
        Facter.add(:ps) do
            setcode do 'ps -ef' end
        end

        Facter.add(:ps) do
            confine :operatingsystem => %w{FreeBSD NetBSD OpenBSD Darwin}
            setcode do 'ps -auxwww' end
        end

        Facter.add(:id) do
            #confine :kernel => %w{Solaris Linux}
            confine :operatingsystem => %w{Solaris Linux Fedora RedHat CentOS SuSE Debian Gentoo}
            setcode "whoami"
        end

