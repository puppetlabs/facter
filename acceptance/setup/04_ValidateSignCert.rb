test_name "Validate Sign Cert"

hostname = on(master, 'facter hostname').stdout.strip                                             
fqdn = on(master, 'facter fqdn').stdout.strip                                                     
                                                                                                  
master_conf = {
  :master => {
    :dns_alt_names => "puppet,#{hostname},#{fqdn}",
  },
}

step "Master: Start Puppet Master"
with_puppet_running_on(master, master_conf) do
  hosts.each do |host|
    next if host['roles'].include? 'master'

    step "Agents: Run agent --test first time to gen CSR"
    on host, puppet_agent("--test"), :acceptable_exit_codes => [1]
  end

  # Sign all waiting certs
  step "Master: sign all certs"
  on master, puppet_cert("--sign --all"), :acceptable_exit_codes => [0,24]

  step "Agents: Run agent --test second time to obtain signed cert"
  on agents, puppet_agent("--test"), :acceptable_exit_codes => [0,2]
end

