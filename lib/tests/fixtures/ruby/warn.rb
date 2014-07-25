Facter.add(:foo) do
    setcode do
        Facter.warn 'message1'
        Facter.warn 'message2'
        nil
    end
end
