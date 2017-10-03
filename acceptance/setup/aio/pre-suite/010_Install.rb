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

  if agent[:platform].match(/(?:el-7|redhat-7)/)
    step "Upgrade openssl package on (" + agent[:platform] + ")" do
    end
    on(agent, "yum -y install openssl-1.0.1e-51.el7_2.4.x86_64")
  else
    step "Skipping upgrade of openssl package... (not redhat platform)" do
    end
  end

  install_puppet_agent_dev_repo_on(hosts, opts)
end

# make sure install is sane, beaker has already added puppet and ruby
# to PATH in ~/.ssh/environment
agents.each do |agent|
  on agent, puppet('--version')
  ruby = Puppet::Acceptance::CommandUtils.ruby_command(agent)
  on agent, "#{ruby} --version"
end
