Facter.add(:id) do
    setcode "whoami"
end

Facter.add(:id) do
    confine :kernel => :SunOS
    setcode "/usr/xpg4/bin/id -un"
end
