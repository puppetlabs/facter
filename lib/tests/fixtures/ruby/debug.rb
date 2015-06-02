Facter.add(:foo) do
    setcode do
        Facter.debug 'message1'
        Facter.debug 'message2'
        nil
    end
end
