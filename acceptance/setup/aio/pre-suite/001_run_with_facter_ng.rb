# frozen_string_literal: true
require 'open3'
require 'tmpdir'

BRANCH_TO_TEST = 'FACT-2598'

def create_facter_gem(branch_name)
  temp_dir = Dir.mktmpdir
  Dir.chdir(temp_dir) do
    download_and_build_facter_ng(branch_name)

    facter_repo_dir = Pathname.new("#{temp_dir}/facter-ng")
    facter_gem_path = Dir.entries(facter_repo_dir).select { |file| file =~ /facter-[0-9]+.[0-9]+.[0-9]+(.pre)?.gem/ }
    File.join(facter_repo_dir, facter_gem_path)
  end
end

def download_and_build_facter_ng(branch_name)
  puts "Cloning branch #{branch_name}"
  Open3.capture2('echo $PATH')

  Open3.capture2("git clone https://github.com/puppetlabs/facter-ng.git &&" \
  'cd facter-ng &&' \
  'git fetch &&' \
  "git reset --hard origin/#{branch_name}")

  Dir.chdir('facter-ng') do
    puts "Latest commit on branch #{branch_name}"
    output, _stderr = Open3.capture2('git log -1')
    puts output

    Open3.capture2('gem build facter.gemspec')
  end
end

def install_facter_gem(agent, facter_gem_path)
  home_dir = on(agent, 'pwd').stdout.chop
  gem_command = gem_command(agent)

  scp_to agent, facter_gem_path, home_dir

  on agent, "#{gem_command} uninstall facter-ng"
  on agent, "#{gem_command} install -f facter-*.gem"

  puts "FACTER VERSION IS"
  on(agent, 'facter -v')
  puts "Puppet facts"
  on(agent, 'puppet facts --trace')
end

test_name 'Setup for Facter NG' do
  windows_puppet_bin_path = '/cygdrive/c/Program\ Files/Puppet\ Labs/Puppet/bin'
  set_facter_ng_command = 'puppet config set facterng true'

  puts 'Setting run with facter ng if environment variable FACTER_NG is true.'
  puts "FACTER_NG is #{ENV["FACTER_NG"]}."

  if ENV["FACTER_NG"] == 'true'
    puts 'Cloning facter ng repository and creating gem file.'
    facter_gem_path = create_facter_gem(BRANCH_TO_TEST)

    agents.each do |agent|
      puts 'Renaming facter to facter-original and facter-ng to facter.'
      if agent['platform'] =~ /windows/
        on agent, %( cmd /c #{set_facter_ng_command} )
        on agent, %( cd #{windows_puppet_bin_path} && mv facter-ng.bat facter.bat )
      else
        on agent, %( #{set_facter_ng_command} )
      end

      puts 'Installing Facter NG on agent.'
      install_facter_gem(agent, facter_gem_path)
    end
  end
end
