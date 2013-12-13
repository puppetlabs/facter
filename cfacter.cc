#include "cfacterlib.h"

#include <iostream>
#include <map>
#include <string>
#include <stdlib.h>

#include "rapidjson/document.h"
#include "rapidjson/prettywriter.h"
#include "rapidjson/stringbuffer.h"

using namespace std;

int main(int argc, char **argv)
{
  std::map<std::string, std::string> facts;
  facts["facterversion"] = "3.0.0";

  list<string> external_directories;
  external_directories.push_back("/etc/facter/facts.d");
  
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
  get_external_facts(facts, external_directories);

  if (0) {
   typedef map<string, string>::iterator iter;
   for (iter i = facts.begin(); i != facts.end(); ++i) {
     cout << i->first << " => " << i->second << endl;
   }
  }
  else {
    rapidjson::Document json;
    json.SetObject();

    rapidjson::Document::AllocatorType& allocator = json.GetAllocator();

    typedef map<string, string>::iterator iter;
    for (iter i = facts.begin(); i != facts.end(); ++i) {
      json.AddMember(i->first.c_str(), i->second.c_str(), allocator);
    }

    rapidjson::StringBuffer buf;
    rapidjson::Writer<rapidjson::StringBuffer> writer(buf);
    json.Accept(writer);

    cout << buf.GetString() << endl;
  }
  exit(0);
}
