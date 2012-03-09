Facter.add(:hostuuid) do
  confine :kernel => :freebsd
  setcode do
    Facter::Util::Resolution.exec('sysctl -n kern.hostuuid')
  end
end
