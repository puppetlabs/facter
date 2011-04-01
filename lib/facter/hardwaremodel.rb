# Fact: hardwaremodel
#
# Purpose:
#   Returns the hardware model of the system.
#
# Resolution:
#   Uses purely "uname -m" on all platforms other than AIX and Windows.
#   On AIX uses the parsed "modelname" output of "lsattr -El sys0 -a modelname".
#   On Windows uses the 'host_cpu' pulled out of Ruby's config.
#
# Caveats:
#

Facter.add(:hardwaremodel) do
    setcode 'uname -m'
end

Facter.add(:hardwaremodel) do
    confine :operatingsystem => :aix
    setcode do
        model = Facter::Util::Resolution.exec('lsattr -El sys0 -a modelname')
        if model =~ /modelname\s(\S+)\s/
            $1
        end
    end
end

Facter.add(:hardwaremodel) do
    confine :operatingsystem => :windows
    setcode do
        require 'rbconfig'
        Config::CONFIG['host_cpu']
    end
end
