Facter.add(:foo) do
  setcode do
    cmd = Gem.win_platform? ? 'cmd /k "exit 99"' : 'sh -c "exit 99"'
    Facter::Core::Execution.execute(cmd);
    $?.exitstatus
  end
end
