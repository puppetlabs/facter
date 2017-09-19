require 'puppet/acceptance/common_utils'
require 'beaker/dsl/install_utils'
extend Beaker::DSL::InstallUtils

test_name "Install Packages"

step "Install puppet-agent..." do
  dev_builds_url  = ENV['DEV_BUILDS_URL'] || 'http://builds.delivery.puppetlabs.net'
  install_from_build_data_url('puppet-agent', "#{dev_builds_url}/puppet-agent/#{ENV['SHA']}/artifacts/#{ENV['SHA']}.yaml")
end

# make sure install is sane, beaker has already added puppet and ruby
# to PATH in ~/.ssh/environment
agents.each do |agent|
  on agent, puppet('--version')
  ruby = Puppet::Acceptance::CommandUtils.ruby_command(agent)
  on agent, "#{ruby} --version"
end
