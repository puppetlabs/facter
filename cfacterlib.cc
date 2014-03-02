#include "cfacterlib.h"
#include "cfacterimpl.h"

#include <iostream>
#include <map>
#include <string>
#include <stdlib.h>

#include "rapidjson/document.h"
#include "rapidjson/prettywriter.h"
#include "rapidjson/stringbuffer.h"

std::map<std::string, std::string> facts;

void clear()
{
    facts.erase(facts.begin(), facts.end());
}

void loadfacts()
{
    // Make loadfacts() idempotent, if client has reason to
    // want a reload, they should clear() then loadfacts().
    //
    // This goes along with to_json() and value() always calling
    // loadfacts().
    //
    if (!facts.empty())
        return;

    facts["cfacterversion"] = "0.0.1";

    std::list<std::string> external_directories;
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
}

int  to_json(char *facts_json, size_t facts_len)
{
    loadfacts();

    rapidjson::Document json;
    json.SetObject();

    rapidjson::Document::AllocatorType& allocator = json.GetAllocator();

    typedef std::map<std::string, std::string>::iterator iter;
    for (iter i = facts.begin(); i != facts.end(); ++i) {
        json.AddMember(i->first.c_str(), i->second.c_str(), allocator);
    }

    rapidjson::StringBuffer buf;
    rapidjson::Writer<rapidjson::StringBuffer> writer(buf);
    json.Accept(writer);

    // FIXME can rapidjson write straight into the provided char array in a safe manner?
    // if not roll my own strncpy which doesn't zero-pad and returns success rather than the ptr
    strncpy(facts_json, buf.GetString(), facts_len);
    return 0;
}

int  value(const char *fact, char *value, size_t value_len)
{
    loadfacts();

    typedef std::map<std::string, std::string>::iterator iter;
    iter i = facts.find(fact);
    if (i == facts.end())
        return -1;

    if (i->second.size() > (value_len - 1))
        return -1;

    strncpy(value, i->second.c_str(), value_len);

    return 0;
}

void search_external(const char *dirs)
{
    // TODO
}
