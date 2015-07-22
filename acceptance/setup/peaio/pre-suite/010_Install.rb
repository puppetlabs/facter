
options['pe_ver'] = hosts[0]['pe_ver'] || options['pe_ver'] ||
    Beaker::Options::PEVersionScraper.load_pe_version(hosts[0][:pe_dir] || options[:pe_dir], options[:pe_version_file])

hosts.each do |host|
    host['type'] = 'aio'
end

install_puppet_agent_dev_repo_on(hosts, { :puppet_agent_version => options[:puppet_agent_version],
                                          :puppet_agent_sha => options[:puppet_agent_sha],
                                          :pe_ver => options[:pe_ver],
                                          :puppet_collection => options[:puppet_collection] })

configure_pe_defaults_on(hosts)
