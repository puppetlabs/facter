#include <map>
#include <string>

typedef std::map<std::string, std::string> fact_map;

void get_network_facts(fact_map&);
void get_kernel_facts(fact_map&);
void get_blockdevice_facts(fact_map&);
void get_operatingsystem_facts(fact_map&);
void get_uptime_facts(fact_map&);
void get_virtual_facts(fact_map&);
void get_hardwired_facts(fact_map&);
void get_misc_facts(fact_map&);
void get_ruby_lib_versions(fact_map&);
void get_mem_facts(fact_map&);
void get_selinux_facts(fact_map&);
void get_ssh_facts(fact_map&);
void get_processor_facts(fact_map&);
void get_architecture_facts(fact_map&);
void get_dmidecode_facts(fact_map&);
void get_filesystems_facts(fact_map&);
void get_hostname_facts(fact_map&);
