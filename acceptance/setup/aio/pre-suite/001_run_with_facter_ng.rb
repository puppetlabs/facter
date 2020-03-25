# frozen_string_literal: true

test_name 'Setup for Facter NG' do
  windows_puppet_bin_path = '/cygdrive/c/Program\ Files/Puppet\ Labs/Puppet/bin'
  linux_puppet_bin_path = '/opt/puppetlabs/puppet/bin'
  linux_bin_path = '/opt/puppetlabs/bin'
  set_facter_ng_command = 'puppet config set facterng true'

  puts 'Setting run with facter ng if environment variable FACTER_NG is true.'
  puts "FACTER_NG is #{ENV["FACTER_NG"]}."

  if ENV["FACTER_NG"] == 'true'
    agents.each do |agent|
      if agent['platform'] =~ /windows/
        on agent, %( cmd /c #{set_facter_ng_command} )
        on agent, %( cd #{windows_puppet_bin_path} && mv facter-ng.bat facter.bat )
      else
        on agent, %( #{set_facter_ng_command} )
        on agent, %( cd #{linux_bin_path} && mv facter facter-original )
        on agent, %( cd #{linux_puppet_bin_path} && mv facter facter-original && mv facter-ng facter)
      end
    end
  end
end
