Facter.add(:foo) do
    setcode do
        # Ensure that the same object is returned from Facter.value for built-in facts
        Facter.value(:facterversion) &&
        Facter.value(:facterversion).object_id == Facter.value(:facterversion).object_id
    end
end
