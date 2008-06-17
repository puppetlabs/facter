Facter.add(:hardwaremodel) do
    setcode 'uname -m'
end

Facter.add(:hardwaremodel) do
    confine :operatingsystem => :aix
    setcode 'lsattr -El proc0 -a type|cut -f2 -d" "'
end
