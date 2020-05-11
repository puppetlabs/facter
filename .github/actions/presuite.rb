require 'open3'

def install_bundler
  message('INSTALL BUNDLER')
  run('gem install bundler')
end

def install_facter_3_dependecies
  message('INSTALL FACTER 3 ACCEPTANCE DEPENDENCIES')
  run('bundle install')
end

def install_custom_beaker
  message('BUILD CUSTOM BEAKER GEM')
  run('gem build beaker.gemspec')

  message('INSTALL CUSTOM BEAKER GEM')
  run('gem install beaker-*.gem')
end

def initialize_beaker
  beaker_options = "#{get_beaker_platform(ENV['ImageOS'].to_sym)}{hypervisor=none\\,hostname=localhost}"

  message('BEAKER INITIALIZE')
  run("beaker init -h #{beaker_options} -o config/aio/options.rb")

  message('BEAKER PROVISION')
  run('beaker provision')
end

def get_beaker_platform(host_platform)
  beaker_platforms = {
      ubuntu18: 'ubuntu1804-64a',
      ubuntu16: 'ubuntu1604-64a',
      macos1015: 'osx1015-64a'
  }

  beaker_platforms[host_platform]
end

def install_puppet_agent
  beaker_puppet_root, _ = run('bundle info beaker-puppet --path')
  install_puppet_file_path = File.join(beaker_puppet_root.chomp, 'setup', 'aio', '010_Install_Puppet_Agent.rb')

  message('INSTALL PUPPET AGENT')
  run("beaker exec pre-suite --pre-suite #{install_puppet_file_path}")
end

def replace_facter_3_with_facter_4
  linux_puppet_bin_dir = '/opt/puppetlabs/puppet/bin'
  gem_command = File.join(linux_puppet_bin_dir, 'gem')
  puppet_command = File.join(linux_puppet_bin_dir, 'puppet')

  message('SET FACTER 4 FLAG TO TRUE')
  run("#{puppet_command} config set facterng true")

  message('BUILD FACTER 4 LATEST AGENT GEM')
  run("#{gem_command} build agent/facter-ng.gemspec", ENV['FACTER_4_ROOT'])

  message('UNINSTALL DEFAULT FACTER 4 AGENT GEM')
  run("#{gem_command} uninstall facter-ng")

  message('INSTALL FACTER 4 GEM')
  run("#{gem_command} install -f facter-ng-*.gem", ENV['FACTER_4_ROOT'])

  message('CHANGE FACTER 3 WITH FACTER 4')
  run('mv facter-ng facter', linux_puppet_bin_dir)
end

def run_acceptance_tests
  message('RUN ACCEPTANCE TESTS')
  run('beaker exec tests --test-tag-exclude=server,facter_3 --test-tag-or=risk:high,audit:high')
end

def message(message)
  message_length = message.length
  total_length = 130
  lines_length = (total_length - message_length) / 2
  result = ('-' * lines_length + ' ' + message + ' ' + '-' * lines_length)[0, total_length]
  puts "\n\n#{result}\n\n"
end

def run(command, dir = './')
  puts command
  output, status = Open3.capture2(command, chdir: dir)
  puts output
  [output, status]
end

ENV['DEBIAN_DISABLE_RUBYGEMS_INTEGRATION'] = 'no_wornings'
FACTER_3_ACCEPTANCE_PATH = File.join(ENV['FACTER_3_ROOT'], 'acceptance')

install_bundler

Dir.chdir(FACTER_3_ACCEPTANCE_PATH) { install_facter_3_dependecies }

Dir.chdir(ENV['BEAKER_ROOT']) { install_custom_beaker }

Dir.chdir(FACTER_3_ACCEPTANCE_PATH) do
  initialize_beaker
  install_puppet_agent
end

replace_facter_3_with_facter_4

Dir.chdir(FACTER_3_ACCEPTANCE_PATH) do
  _, status = run_acceptance_tests
  exit(status.exitstatus)
end
