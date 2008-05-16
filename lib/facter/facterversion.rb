Facter.add(:facterversion) do
    setcode { Facter::FACTERVERSION.to_s }
end
