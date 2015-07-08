Facter.add(:first) do
    setcode do
        Facter::Core::Execution.exec("echo foo 1>&2 && echo bar")
    end
end

Facter.add(:second) do
    setcode 'echo foo 1>&2 && echo bar'
end
