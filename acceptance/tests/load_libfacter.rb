test_name 'Ruby can load libfacter'

agents.each do |agent|
  on agent, "env PATH=\"#{agent['privatebindir']}:${PATH}\" which ruby"
  ruby_path = stdout.chomp

  root_dir = ruby_path
  while File.basename(root_dir).downcase != 'puppet'
    new_root_dir = File.dirname(root_dir)
    if new_root_dir == root_dir
      break
    else
      root_dir = new_root_dir
    end
  end

  if agent.platform.variant == 'windows'
    root_dir = on(agent, "cygpath -w '#{root_dir}'").stdout.chomp
    facter_loader = "#{root_dir}/facter/lib/facter.rb"
    path = '/cygdrive/c/Windows/system32:/cygdrive/c/Windows'
  else
    facter_loader = "#{root_dir}/lib/ruby/vendor_ruby/facter.rb"
    path = '/usr/local/bin:/bin:/usr/bin'
  end

  # Ensure privatebindir comes first so we get the correct Ruby version.
  on agent, "env PATH=#{path} \"#{ruby_path}\" \"#{facter_loader}\"" do
    assert_empty stdout
    assert_empty stderr
  end
end
