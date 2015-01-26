Facter.add(:facterversion) do
    setcode do
        # This tests a custom fact that attempts to override a built-in fact
        # but does not resolve to a value; the built-in fact should
        # not be overridden
        nil
    end
end
