require 'puppet/acceptance/common_utils'
require 'beaker/dsl/install_utils'
extend Beaker::DSL::InstallUtils

test_name "Install Packages"

step "Install puppet-agent..." do
  opts = {
    :puppet_collection    => 'PC1',
    :puppet_agent_sha     => ENV['SHA'],
    :puppet_agent_version => ENV['SUITE_VERSION'] || ENV['SHA']
  }
  install_puppet_agent_dev_repo_on(hosts, opts)
end

# make sure install is sane, beaker has already added puppet and ruby
# to PATH in ~/.ssh/environment
agents.each do |agent|
  if agent['platform'] =~ /cisco-5/
    on agent, "sudo chmod +x /etc/profile.d/puppet-agent.sh"
  end
  on agent, puppet('--version')
  ruby = Puppet::Acceptance::CommandUtils.ruby_command(agent)
  on agent, "#{ruby} --version"
end
