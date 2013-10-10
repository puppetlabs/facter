test_name "Puppet Master sanity checks: PID file and SSL dir creation"

pidfile = '/var/lib/puppet/run/master.pid'

hostname = on(master, 'facter hostname').stdout.strip                                             
fqdn = on(master, 'facter fqdn').stdout.strip                                                     
                                                                                                  
master_conf = {
  :main => {
    :dns_alt_names => "puppet,#{hostname},#{fqdn}",
    :verbose => true,
    :noop => true,
  },
}

with_puppet_running_on(master, master_conf) do
  # SSL dir created?
  step "SSL dir created?"
  on master,  "[ -d #{master['puppetpath']}/ssl ]"

  # PID file exists?
  step "PID file created?"
  on master, "[ -f #{pidfile} ]"
end
