test_name 'C100161: Ruby can load libfacter without raising an error' do
  tag 'risk:high'

  require 'puppet/acceptance/common_utils'
  extend Puppet::Acceptance::CommandUtils

  def puppet_ruby_path_to_puppet_install_dir(puppet_ruby_path)
    # find the "puppet" directory which should be the root of the install
    puppet_dir = puppet_ruby_path
    while File.basename(puppet_dir).downcase != 'puppet'
      new_puppet_dir = File.dirname(puppet_dir)
      if new_puppet_dir == puppet_dir
        break
      else
        puppet_dir = new_puppet_dir
      end
    end
    puppet_dir
  end

  agents.each do |agent|
    # on Windows we have to figure out where facter.rb is so we can include the path
    if agent['platform'] =~ /windows/
      # figure out the root of the puppet installation
      puppet_ruby_path = on(agent, "env PATH=\"#{agent['privatebindir']}:${PATH}\" which ruby").stdout.chomp
      cygwin_puppet_root = puppet_ruby_path_to_puppet_install_dir(puppet_ruby_path)
      puppet_root = on(agent, "cygpath -w '#{cygwin_puppet_root}'").stdout.chomp
      include_facter_lib = "-I '#{puppet_root}/facter/lib'"
    else
      # facter.rb is already in the load path for ruby
      include_facter_lib = ""
    end

    # Run Puppet's ruby and load facter.rb
    # if we fail to load the .jar or .so, ruby will see an error raised for us to detect
    on(agent, "#{ruby_command(agent)} -e \"require 'facter'\" #{include_facter_lib} ") do |ruby_result|
      assert_empty(ruby_result.stdout, 'Expected libfacter to load without any output on stdout')
      assert_empty(ruby_result.stderr, 'Expected libfacter to load without any output on stderr')
    end
  end
end