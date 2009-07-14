Facter.add(:path) do
    setcode do
        ENV['PATH']
    end
end
