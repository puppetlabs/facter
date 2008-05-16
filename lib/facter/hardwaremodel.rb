        Facter.add(:hardwaremodel) do
            setcode 'uname -m'
        end
