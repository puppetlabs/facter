   Facter.add(:kernelrelease) do
            setcode 'uname -r'
        end
