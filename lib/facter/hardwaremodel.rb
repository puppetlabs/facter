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
