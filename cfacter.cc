#include "cfacterlib.h"

#include <iostream>
#include <map>
#include <string>
#include <stdlib.h>

using namespace std;

int main(int argc, char **argv)
{
  std::map<std::string, std::string> facts;
  facts["facterversion"] = "3.0.0";
  
  get_network_facts(facts);
  get_kernel_facts(facts);
  get_blockdevice_facts(facts);
  get_operatingsystem_facts(facts);
  get_uptime_facts(facts);
  get_virtual_facts(facts);
  get_hardwired_facts(facts);
  get_misc_facts(facts);
  get_ruby_lib_versions(facts);
  get_mem_facts(facts);
  get_selinux_facts(facts);
  get_ssh_facts(facts);
  get_processor_facts(facts);
  get_architecture_facts(facts);
  get_dmidecode_facts(facts);
  get_filesystems_facts(facts);
  get_hostname_facts(facts);

  typedef map<string, string>::iterator iter;
  for (iter i = facts.begin(); i != facts.end(); ++i) {
    cout << i->first << " => " << i->second << endl;
  }
  exit(0);
}
