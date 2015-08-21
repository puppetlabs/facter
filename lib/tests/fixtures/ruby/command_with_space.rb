Facter.add('foo') do
  setcode do
    Facter::Util::Resolution.exec('command_with_space.bat bar')
  end
end
