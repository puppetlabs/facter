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

   # Move the openssl libs package to a newer version on redhat platforms
   use_system_openssl = ENV['USE_SYSTEM_OPENSSL']

   if use_system_openssl && agent[:platform].match(/(?:el-7|redhat-7)/)
     rhel7_openssl_version = ENV['RHEL7_OPENSSL_VERSION']
     if rhel7_openssl_version.to_s.empty?
       # Fallback to some default is none is provided
       rhel7_openssl_version = "openssl-1.0.1e-51.el7_2.4.x86_64"
     end
     on(agent, "yum -y install " +  rhel7_openssl_version)
   else
     step "Skipping upgrade of openssl package... (" + agent[:platform] + ")"
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
