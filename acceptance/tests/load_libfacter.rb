# Verify that we can load the facter the way that mco does based on the platform
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
    # create a ruby program that will add a fact through Facter
    fact_content = <<-EOM
    require 'facter'
    Facter.add('facter_loaded') do
      setcode do
        'FACTER_LOADED'
      end
    end

    # print a value so that we know that facter loaded and is working
    puts Facter.value('facter_loaded')
    exit 0
    EOM

    fact_dir = agent.tmpdir('mco_test')
    fact_program = File.join(fact_dir, 'loading_facter.rb')
    create_remote_file(agent, fact_program, fact_content)

    teardown do
      on(agent, "rm -rf '#{fact_dir}'")
    end

    if agent['platform'] =~ /windows/ && agent.is_cygwin?
      # on Windows we have to figure out where facter.rb is so we can include the path
      # figure out the root of the Puppet installation
      puppet_ruby_path = on(agent, "env PATH=\"#{agent['privatebindir']}:${PATH}\" which ruby").stdout.chomp
      cygwin_puppet_root = puppet_ruby_path_to_puppet_install_dir(puppet_ruby_path)
      puppet_root = on(agent, "cygpath -w '#{cygwin_puppet_root}'").stdout.chomp
      # on Windows mco uses -I to include the path to the facter.rb as its not in the
      # default $LOAD_PATH for Puppets Ruby
      include_facter_lib = "-I '#{puppet_root}/facter/lib'"
    else
      # On Unix systems facter.rb is already in the $LOAD_PATH for Puppets Ruby for mco
      include_facter_lib = ''
    end

    # Run Puppet's ruby and load facter.rb
    # if we fail to load the .jar or .so, ruby will raise an error for us to detect
    on(agent, "#{ruby_command(agent)} #{include_facter_lib} #{fact_program}") do |ruby_result|
      assert_equal('FACTER_LOADED', ruby_result.stdout.chomp, 'Expected the output to be only the value the added fact')
      assert_empty(ruby_result.stderr, 'Expected libfacter to load without any output on stderr')
    end
  end
end
