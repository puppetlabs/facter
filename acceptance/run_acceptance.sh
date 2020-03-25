#!/bin/sh -x
beaker init -h fedora31-64a -o config/aio/options.rb
beaker provision

export BP_ROOT=/Users/andrei.filipovici/projects/beaker-puppet
export SHA=`curl --fail --silent GET --url http://builds.delivery.puppetlabs.net/passing-agent-SHAs/puppet-agent-master`

bundle exec beaker exec pre-suite --pre-suite $BP_ROOT/setup/common/000-delete-puppet-when-none.rb,$BP_ROOT/setup/aio/010_Install_Puppet_Agent.rb
bundle exec beaker exec pre-suite

beaker exec tests 2>&1 | tee $log
