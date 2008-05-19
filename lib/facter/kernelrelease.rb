   Facter.add(:kernelrelease) do
            setcode 'uname -r'
        end

   Facter.add(:kernelrelease) do
            confine :kernel => :aix
            setcode 'oslevel -s'
        end
