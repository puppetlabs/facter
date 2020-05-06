#!/bin/sh -x

export DEBIAN_DISABLE_RUBYGEMS_INTEGRATION=no_wornings
export PATH=/opt/puppetlabs/bin/:/opt/puppetlabs/puppet/bin:$PATH

cwd=$(pwd)

printf '\nInstall bundler\n\n'
gem install bundler

printf '\nInstall facter 3 acceptance dependencies\n\n'
cd $cwd/$FACTER_3_ROOT/acceptance && bundle install

printf '\nInstall custom beaker\n\n'
cd $cwd/$BEAKER_ROOT
gem build beaker.gemspec
gem install beaker-*.gem --bindir /bin

printf '\nBeaker provision\n\n'
cd $cwd/$FACTER_3_ROOT/acceptance
beaker init -h ubuntu1804-64a{hypervisor=none\,hostname=localhost} -o config/aio/options.rb
beaker provision

printf '\nBeaker pre-suite\n\n'
BP_ROOT=`bundle info beaker-puppet --path`
beaker exec pre-suite --pre-suite $BP_ROOT/setup/aio/010_Install_Puppet_Agent.rb

printf '\nConfigure facter 4 as facter 3\n\n'
puppet config set facterng true

cd $cwd/$FACTER_4_ROOT
puppet_gem_command=/opt/puppetlabs/puppet/bin/gem
$puppet_gem_command build agent/facter-ng.gemspec
$puppet_gem_command uninstall facter-ng
$puppet_gem_command install -f facter-ng-*.gem

cd /opt/puppetlabs/puppet/bin
mv facter-ng facter

printf "\nFacter version\n\n"
facter --version

printf "\Puppet facts facter version\n\n"
puppet facts | grep facterversion

printf '\nBeaker tests\n\n'
cd $cwd/$FACTER_3_ROOT/acceptance
beaker exec tests --test-tag-exclude=server,facter_3 --test-tag-or=risk:high,audit:high 2>&1
