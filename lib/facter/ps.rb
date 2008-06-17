Facter.add(:ps) do
    setcode do 'ps -ef' end
end

Facter.add(:ps) do
    confine :operatingsystem => %w{FreeBSD NetBSD OpenBSD Darwin}
    setcode do 'ps auxwww' end
end
