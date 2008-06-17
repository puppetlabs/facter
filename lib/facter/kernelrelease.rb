   Facter.add(:kernelrelease) do
            setcode 'uname -r'
        end

   Facter.add(:kernelrelease, :timeout => 5) do
            confine :kernel => :aix
            setcode 'oslevel -s'
        end
