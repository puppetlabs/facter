test_name "Setup environment"

step "Ensure Git and Ruby"

require 'puppet/acceptance/install_utils'
extend Puppet::Acceptance::InstallUtils
require 'puppet/acceptance/git_utils'
extend Puppet::Acceptance::GitUtils
require 'beaker/dsl/install_utils'
extend Beaker::DSL::InstallUtils

PACKAGES = {
  :redhat => [
    'git',
    'ruby',
    'rubygem-json',
  ],
  :debian => [
    ['git', 'git-core'],
    'ruby',
  ],
  :debian_ruby18 => [
    'libjson-ruby',
  ],
  :solaris10 => [
    ['git',         'git'],
    ['ruby',        'ruby18'],
    ['ruby-dev',    'ruby18_dev'],
    ['gcc',         'gcc4core'],
    ['ruby18_gcc4', 'ruby18_dev'],
    ['ruby-json',   'rb18_json_1_5_3'],
  ],
  :solaris11 => [
    ['git',  'developer/versioning/git'],
    ['ruby', 'runtime/ruby-18'],
    # there isn't a package for json, so it is installed later via gems
  ],
  :windows => [
    'git',
    # there isn't a need for json on windows because it is bundled in ruby 1.9
  ],
}

hosts.each do |host|
  case host['platform']
  when  /solaris-11/
    on host, 'if ((`pkg publisher | wc -l` < 2)); then pkg set-publisher -P -g http://pkg.oracle.com/solaris/release/ solaris; fi'
  when  /solaris-10/
    on host, 'mkdir -p /var/lib'
    on host, 'ln -s /opt/csw/bin/pkgutil /usr/bin/pkgutil'
    on host, 'ln -s /opt/csw/bin/gem18 /usr/bin/gem'
    on host, 'ln -s /opt/csw/bin/git /usr/bin/git'
    on host, 'ln -s /opt/csw/bin/ruby18 /usr/bin/ruby'
  end
end

install_packages_on(hosts, PACKAGES, :check_if_exists => true)

hosts.each do |host|
  case host['platform']
  when /windows/
    step "#{host} Install ruby from git"
    ruby_arch = host[:ruby_arch] || 'x86'
    revision = if ruby_arch == 'x64'
                 '2.0.0-x64'
               else
                 '1.9.3-x86'
               end

    install_from_git(host, "/opt/puppet-git-repos",
                    :name => 'puppet-win32-ruby',
                    :path => build_giturl('puppet-win32-ruby'),
                    :rev  => revision)
    on host, 'cd /opt/puppet-git-repos/puppet-win32-ruby; cp -r ruby/* /'
    on host, 'cd /lib; icacls ruby /grant "Everyone:(OI)(CI)(RX)"'
    on host, 'cd /lib; icacls ruby /reset /T'
    on host, 'cd /; icacls bin /grant "Everyone:(OI)(CI)(RX)"'
    on host, 'cd /; icacls bin /reset /T'
    on host, 'ruby --version'
    on host, 'cmd /c gem list'
  when /solaris-11/
    step "#{host} Install json from rubygems"
    on host, 'gem install json'
  end
end
