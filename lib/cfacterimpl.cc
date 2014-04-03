#include <dirent.h>
#include <inttypes.h>
#include <cstdio>
#include <cstdlib>
#include <unistd.h>
#include <cstring>
#include <sys/ioctl.h>
#include <sys/socket.h>
#include <sys/types.h>
#include <sys/utsname.h>
#ifdef __linux__
#include <linux/if.h>
#endif
#ifdef __APPLE__
#include <net/if.h>
#endif
#include <netinet/in.h>
#include <arpa/inet.h>
#include <sys/stat.h>

#include <algorithm>
#include <fstream>
#include <iostream>
#include <iomanip>
#include <iterator>
#include <list>
#include <map>
#include <string>
#include <sstream>
#include <string>
#include <vector>

#include "cfacterlib.h"
#include "cfacterimpl.h"
#include "scoped_resource.hpp"

using namespace std;
using namespace cfacter;

// For case-insensitive strings, define ci_string
// Thank you, Herb Sutter: http://www.gotw.ca/gotw/029.htm
//
struct ci_char_traits : public char_traits<char>
// just inherit all the other functions
//  that we don't need to override
{
    static bool eq(char c1, char c2)
    {
        return toupper(c1) == toupper(c2);
    }

    static bool ne(char c1, char c2)
    {
        return toupper(c1) != toupper(c2);
    }

    static bool lt(char c1, char c2)
    {
        return toupper(c1) <  toupper(c2);
    }

    static int compare(char const* s1, char const* s2, size_t n)
    {
        return strncasecmp(s1, s2, n);
        // if available on your compiler,
        //  otherwise you can roll your own
    }

    static char const* find(char const* s, int n, char a)
    {
        while (n-- > 0 && toupper(*s) != toupper(a)) {
            ++s;
        }
        return s;
    }
};

typedef basic_string<char, ci_char_traits> ci_string;

// trim from start
static inline string& ltrim(string& s)
{
    s.erase(s.begin(), find_if(s.begin(), s.end(), not1(ptr_fun<int, int>(isspace))));
    return s;
}

// trim from end
static inline string& rtrim(string& s)
{
    s.erase(find_if(s.rbegin(), s.rend(), not1(ptr_fun<int, int>(isspace))).base(), s.end());
    return s;
}

// trim from both ends
static inline string& trim(string& s)
{
    return ltrim(rtrim(s));
}

static inline void tokenize(string const& s, vector<string>& tokens)
{
    istringstream iss(s);
    copy(istream_iterator<string>(iss),
         istream_iterator<string>(),
         back_inserter<vector<string> >(tokens));
}

static inline void split(string const& s, char delim, vector<string>& elems)
{
    stringstream ss(s);
    string item;
    while (getline(ss, item, delim)) {
        elems.push_back(item);
    }
}

static bool file_exist(string const& filename)
{
    struct stat buffer;
    return stat (filename.c_str(), &buffer) == 0;
}

// handy for some /proc and /sys files
string read_oneline_file(string const& file_path)
{
    ifstream oneline_file(file_path.c_str(), ifstream::in);
    string line;
    getline(oneline_file, line);
    return line;
}

void get_network_facts(fact_map& facts)
{
    scoped_descriptor sock(socket(AF_INET, SOCK_DGRAM, 0));

    if (sock < 0) {
        perror("socket");
        exit(1);
    }

    // find number of interfaces.
    ifconf ifc;
    memset(&ifc, 0, sizeof(ifc));
    if (ioctl(sock, SIOCGIFCONF, &ifc) < 0) {
        perror("ioctl");
        exit(1);
    }

    vector<ifreq> ifreqs(ifc.ifc_len / sizeof(ifreq));
    ifc.ifc_ifcu.ifcu_req = ifreqs.data();

    if (ioctl(sock, SIOCGIFCONF, &ifc) < 0) {
        perror("ioctl SIOCGIFCONF");
        exit(1);
    }

    string interfaces = "";

    bool primaryInterfacePrinted = false;
    for (auto& req : ifreqs) {
        auto const& ip_addr = reinterpret_cast<sockaddr_in const*>(&req.ifr_addr)->sin_addr;

        // no idea what the real algorithm is to identify the unmarked
        // interface, i.e. the one that facter reports as just 'ipaddress'
        // here just take the first one that's not 'lo'
        bool primaryInterface = false;
        if (!primaryInterfacePrinted && strcmp(req.ifr_name, "lo")) {
            // this is the chosen interface
            primaryInterface = true;
            primaryInterfacePrinted = true;
        }

        // build up 'interfaces' fact as we go
        if (!interfaces.empty()) {
          interfaces += ",";
        }
        interfaces += req.ifr_name;

        char const* ipaddress = inet_ntoa(ip_addr);
        facts[string("ipaddress_") + req.ifr_name] = ipaddress;
        if (primaryInterface) {
            facts["ipaddress"] = ipaddress;
        }

        // mtu
        if (ioctl(sock, SIOCGIFMTU, &req) < 0) {
            perror("ioctl SIOCGIFMTU");
            exit(1);
        }

        facts[string("mtu_") + req.ifr_name] = to_string(req.ifr_mtu);
        if (primaryInterface) {}  // no unmarked version of this network fact

        // netmask and network are both derived from the same ioctl
        if (ioctl(sock, SIOCGIFNETMASK, &req) < 0) {
            perror("ioctl SIOCGIFNETMASK");
            exit(1);
        }

#ifndef __APPLE__  // ifr_netmask isn't supported, might need to use SC library
        // netmask
        auto const& netmask_addr = reinterpret_cast<sockaddr_in const*>(&req.ifr_netmask)->sin_addr;
        const char *netmask = inet_ntoa(netmask_addr);
        facts[string("netmask_") + req.ifr_name] = netmask;
        if (primaryInterface)
            facts["netmask"] = netmask;

        // mess of casting to get the network address
        in_addr network_addr;
        network_addr.s_addr =
            (in_addr_t) uint32_t(netmask_addr.s_addr) & uint32_t(ip_addr.s_addr);
        string network = inet_ntoa(network_addr);
        facts[string("network_") + req.ifr_name] = network;
        if (primaryInterface)
            facts["network"] = network;
#endif

#ifndef __APPLE__  // SIOCGIFHWADDR isn't supported, might need to use SC library
        // and the mac address (but not for loopback)
        if (strcmp(req.ifr_name, "lo")) {
            if (ioctl(sock, SIOCGIFHWADDR, &req) < 0) {
                perror("ioctl SIOCGIFHWADDR");
                exit(1);
            }

            // extract mac into a string, okay a char array
            uint8_t *mac_bytes = reinterpret_cast<uint8_t *>((reinterpret_cast<sockaddr *>(&req.ifr_hwaddr))->sa_data);
            char mac_address[18];
            snprintf(mac_address, sizeof(mac_address),
                     "%02x:%02x:%02x:%02x:%02x:%02x",
                     mac_bytes[0], mac_bytes[1], mac_bytes[2],
                     mac_bytes[3], mac_bytes[4], mac_bytes[5]);

            // and get it out
            facts[string("macaddress_") + req.ifr_name] = mac_address;
            if (primaryInterface)
                facts["macaddress"] = mac_address;
        }
#endif
    }

    facts["interfaces"] = interfaces;
}

void get_kernel_facts(fact_map& facts)
{
#ifdef __linux__
    // this is linux-only, so there you have it
    facts["kernel"] = "Linux";
    string kernelrelease = read_oneline_file("/proc/sys/kernel/osrelease");
    facts["kernelrelease"] = kernelrelease;
    string kernelversion = kernelrelease.substr(0, kernelrelease.find("-"));
    facts["kernelversion"] = kernelversion;
    string kernelmajversion = kernelversion.substr(0, kernelversion.rfind("."));
    facts["kernelmajversion"] = kernelmajversion;
#else
#ifdef __APPLE__
    facts["kernel"] = "Darwin";
#endif
#endif
}

static void get_lsb_facts(fact_map& facts)
{
    ifstream lsb_release_file("/etc/lsb-release", ifstream::in);
    string line;
    while (getline(lsb_release_file, line)) {
        unsigned sep = line.find("=");
        string key = line.substr(0, sep);
        string value = line.substr(sep + 1, string::npos);

        if (key == "DISTRIB_ID") {
            facts["lsbdistid"] = value;
            facts["operatingsystem"] = value;
            facts["osfamily"] = "Debian";
        } else if (key == "DISTRIB_RELEASE") {
            facts["lsbdistrelease"] = value;
            facts["operatingsystemrelease"] = value;
            facts["lsbmajdistrelease"] = value.substr(0, value.find("."));
        } else if (key == "DISTRIB_CODENAME") {
            facts["lsbdistcodename"] = value;
        } else if (key == "DISTRIB_DESCRIPTION") {
            facts["lsbdistdescription"] = value;
        }
    }
}

// gonna need to pick a regex library to do os facts rights given all the variants
// for now, just fedora ;>

static void get_redhat_facts(fact_map& facts)
{
    if (file_exist("/etc/redhat-release")) {
        facts["osfamily"] = "RedHat";
        string redhat_release = read_oneline_file("/etc/redhat-release");
        vector<string> tokens;
        tokenize(redhat_release, tokens);
        if (tokens.size() >= 2 && tokens[0] == "Fedora" && tokens[1] == "release") {
            facts["operatingsystem"] = "Fedora";
            if (tokens.size() >= 3) {
                facts["operatingsystemrelease"] = tokens[2];
                facts["operatingsystemmajrelease"] = tokens[2];
            }
        } else {
            facts["operatingsystem"] = "RedHat";
        }
    }
}

void get_operatingsystem_facts(fact_map& facts)
{
    get_lsb_facts(facts);
    get_redhat_facts(facts);
}

void get_uptime_facts(fact_map& facts)
{
    string uptime = read_oneline_file("/proc/uptime");
    unsigned int uptime_seconds;
    sscanf(uptime.c_str(), "%ud", &uptime_seconds);
    unsigned int uptime_hours = uptime_seconds / 3600;
    unsigned int uptime_days  = uptime_hours   / 24;
    facts["uptime_seconds"] = to_string(uptime_seconds);
    facts["uptime_hours"] =   to_string(uptime_hours);
    facts["uptime_days"] =    to_string(uptime_days);
    facts["uptime"] =         to_string(uptime_days) + " days";
}

string popen_stdout(string const& cmd)
{
    FILE *cmd_fd = popen(cmd.c_str(), "r");
    string cmd_output = "";
    char buf[1024];
    size_t bytesRead;
    while ((bytesRead = fread(buf, 1, sizeof(buf) - 1, cmd_fd))) {
        buf[bytesRead] = 0;
        cmd_output += buf;
    }
    pclose(cmd_fd);
    return cmd_output;
}

void get_virtual_facts(fact_map& facts)
{
    // poked at the real facter's virtual support, some combo of file existence
    // plus lspci plus dmidecode

    // instead of parsing all of lspci, how about looking for vendors in lspci -n?
    // or walking the /sys/bus/pci/devices files.  or don't sweat it, the total
    // lspci time is ~40 ms.

    // virtual could be discovered in lots of places so requires some special handling

    facts["is_virtual"] = "false";
    facts["virtual"] = "physical";
}

// placeholders for some hardwired facts, cuz not sure what to do with them
void get_hardwired_facts(fact_map& facts)
{
    facts["ps"] = "ps -ef";  // what is this?
    facts["uniqueid"] = "007f0101";  // ??
}


// versions of things we don't have if we're not running ruby
// omit or 'undef' or ...?  for now, omit but collect them here
void get_ruby_lib_versions(fact_map& facts)
{
    /*
      facts["puppetversion => undef";
      facts["augeasversion => undef";
      facts["rubysitedir => undef";
      facts["rubyversion => undef";
    */
}

// block devices
void get_blockdevice_facts(fact_map& facts)
{
    string blockdevices = "";

    DIR* sys_block_dir = opendir("/sys/block");
    if (!sys_block_dir) {
        return;
    }

    dirent* bd;
    while ((bd = readdir(sys_block_dir))) {
        bool real_block_device = false;
        string device_dir_path = "/sys/block/";
        device_dir_path += bd->d_name;

        DIR *device_dir = opendir(device_dir_path.c_str());
        dirent* subdir;
        while ((subdir = readdir(device_dir))) {
            if (strcmp(subdir->d_name, "device") == 0) {
                // we have a winner
                real_block_device = true;
                break;
            }
        }

        if (!real_block_device) continue;

        // add it to the blockdevices list, careful with the comma
        if (!blockdevices.empty())
            blockdevices += ",";
        blockdevices += bd->d_name;

        string model_file = "/sys/block/" + string(bd->d_name) + "/device/model";
        facts[string("blockdevice_") + bd->d_name + "_model"] =
            read_oneline_file(model_file);

        string vendor_file = "/sys/block/" + string(bd->d_name) + "/device/vendor";
        facts[string("blockdevice_") + bd->d_name + "_vendor"] =
            read_oneline_file(vendor_file);

        string size_file = "/sys/block/" + string(bd->d_name) + "/size";
        string size_line = read_oneline_file(size_file);
        int64_t size;
        sscanf(size_line.c_str(), "%" SCNd64, &size);
        facts[string("blockdevice_") + bd->d_name + "_size"] = to_string(size * 512);
    }

    facts["blockdevices"] = blockdevices;
}

void get_misc_facts(fact_map& facts)
{
    facts["path"] = getenv("PATH");
    string whoami = popen_stdout("whoami");
    facts["id"] = trim(whoami);

    // timezone
    char tzstring[16];
    time_t t = time(nullptr);
    tm loc;
    localtime_r(&t, &loc);
    strftime(tzstring, sizeof(tzstring), "%Z", &loc);
    facts["timezone"] = tzstring;
}

// get just one fact, optionally in two formats
static void get_mem_fact(string const& fact_name, int fact_value, fact_map& facts,
                         bool get_mb_variant = true)
{
    float fact_value_scaled = fact_value / 1024.0;
    char float_buf[32];

    if (get_mb_variant) {
        snprintf(float_buf, sizeof(float_buf) - 1, "%.2f", fact_value_scaled);
        facts[string(fact_name) + "_mb"] = float_buf;
    }

    int scale_index;
    for (scale_index = 0;
            fact_value_scaled > 1024.0;
            fact_value_scaled /= 1024.0, ++scale_index) {}

    string scale[4] = {"MB", "GB", "TB", "PB"};  // oh yeah, petabytes ...

    snprintf(float_buf, sizeof(float_buf) - 1, "%.2f", fact_value_scaled);
    facts[fact_name] = string(float_buf) + scale[scale_index];
}

void get_mem_facts(fact_map& facts)
{
    ifstream oneline_file("/proc/meminfo", ifstream::in);
    string line;

    // The MemFree fact is the sum of MemFree + Buffer + Cached from /proc/meninfo,
    // so sum that one as we go, and get it out at the end.
    // The other three memory facts are straight from /proc/meminfo, so get those
    // as we go.
    // All four facts are geted in two formats:
    //   <fact>_mb => %.2f
    //   <fact>  => %.2f %s  (where the suffix string is one of MB/GB/TB)
    // And then there is a ninth fact, 'memorytotal', which is the same as 'memorysize'.
    //

    // NB: this all assumes that all values are in KB.

    unsigned int memoryfree = 0;

    while (getline(oneline_file, line)) {
        vector<string> tokens;
        tokenize(line, tokens);
        if (tokens.size() < 3) continue;  // should never happen

        if (tokens[0] == "MemTotal:") {
            int mem_total = atoi(tokens[1].c_str());
            get_mem_fact("memorysize", mem_total, facts);
            get_mem_fact("memorytotal", mem_total, facts, false);
        } else if (tokens[0] == "MemFree:" || tokens[0] == "Cached:" || tokens[0] == "Buffers:") {
            memoryfree += atoi(tokens[1].c_str());
        } else if (tokens[0] == "SwapTotal:") {
            get_mem_fact("swapsize", atoi(tokens[1].c_str()), facts);
        } else if (tokens[0] == "SwapFree:") {
            get_mem_fact("swapfree", atoi(tokens[1].c_str()), facts);
        }
    }

    get_mem_fact("memoryfree", memoryfree, facts);
}

static string get_selinux_path()
{
    static string selinux_path = "";
    static bool        inited       = false;

    if (inited)
        return selinux_path;

    ifstream mounts("/proc/self/mounts", ifstream::in);
    string line;

    while (getline(mounts, line)) {
        vector<string> tokens;
        tokenize(line, tokens);
        if (tokens.size() < 2) continue;
        if (tokens[0] != "selinuxfs") continue;

        selinux_path = tokens[1];
        break;
    }

    inited = true;

    return selinux_path;
}

static bool selinux()
{
    string selinux_path = get_selinux_path();
    if (selinux_path.empty())
        return false;

    string selinux_enforce_path = selinux_path + "/enforce";
    string security_attr_path   = "/proc/self/attr/current";
    if (file_exist(selinux_enforce_path) && file_exist(security_attr_path) &&
            read_oneline_file(security_attr_path) != "kernel")
        return true;

    return false;
}

void get_selinux_facts(fact_map& facts)
{
    if (!selinux()) {
        facts["selinux"] = "false";
        return;
    }

    facts["selinux"] = "true";

    // defaults from facter
    facts["selinux_enforced"] = "false";
    facts["selinux_policyversion"] = "unknown";
    facts["selinux_current_mode"] = "unknown";
    facts["selinux_config_mode"] = "unknown";
    facts["selinux_config_policy"] = "unknown";
    facts["selinux_mode"] = "unknown";

    string selinux_path = get_selinux_path();

    string selinux_enforce_path = selinux_path + "/enforce";
    if (file_exist(selinux_enforce_path))
        facts["selinux_enforced"] = ((read_oneline_file(selinux_enforce_path) == "1") ? "true" : "false");

    string selinux_policyvers_path = selinux_path + "/policyvers";
    if (file_exist(selinux_policyvers_path))
        facts["selinux_policyversion"] = read_oneline_file(selinux_policyvers_path);

    string selinux_cmd = "/usr/sbin/sestatus";
    FILE* pipe = popen(selinux_cmd.c_str(), "r");
    if (!pipe) return;

    char buffer[512];   // seems like a lot, but there's no constant available
    while (!feof(pipe)) {
        if (fgets(buffer, 128, pipe) != nullptr) {
            vector<string> elems;
            split(buffer, ':', elems);
            if (elems.size() < 2) continue;  // shouldn't happen
            if (elems[0] == "Current mode") {
                facts["selinux_current_mode"] = trim(elems[1]);
            } else if (elems[0] == "Mode from config file") {
                facts["selinux_config_mode"] = trim(elems[1]);
            } else if (elems[0] == "Policy from config file") {
                facts["selinux_config_policy"] = trim(elems[1]);
                facts["selinux_mode"] = trim(elems[1]);
            }
        }
    }

    pclose(pipe);
}

static void get_ssh_fact(string const& fact_name, string const& path_name, fact_map& facts)
{
    vector<std::string> ssh_directories = {
        "/etc/ssh",
        "/usr/local/etc/ssh",
        "/etc",
        "/usr/local/etc",
        "/etc/opt/ssh",
    };

    for (auto const &ssh_directory : ssh_directories) {
        string full_path = ssh_directory + "/" + path_name;
        if (file_exist(full_path)) {
            string key = read_oneline_file(full_path);
            vector<string> tokens;
            tokenize(trim(key), tokens);
            if (tokens.size() < 2) continue;  // should never happen
            facts[fact_name] = tokens[1];

            // skpping the finger print facts, which require base64 decode and sha libs
            // on the cmd line it would be something like the result of these two:
            //  "cat " + full_path + " | cut -d' ' -f 2 | base64 -d - | sha256sum - | cut -d' ' -f 1"
            //  "cat " + full_path + " | cut -d' ' -f 2 | base64 -d - | sha1sum   - | cut -d' ' -f 1"

            break;
        }
    }
}

// no support for the sshfp facts, which require base64/sha1sum code
void get_ssh_facts(fact_map& facts)
{
    map<string, string> ssh_facts = {
        { "sshdsakey",   "ssh_host_dsa_key.pub"   },
        { "sshrsakey",   "ssh_host_rsa_key.pub"   },
        { "sshecdsakey", "ssh_host_ecdsa_key.pub" },
    };

    for (auto const& i : ssh_facts) {
        get_ssh_fact(i.first, i.second, facts);
    }
}

static void get_physicalprocessorcount_fact(fact_map& facts)
{
    // So, facter has logic to use /sys and fallback to /proc
    // but I don't know why the /sys support was added; research needed.
    // Since sys is the default, just reproduce that logic for now.

    string sysfs_cpu_directory = "/sys/devices/system/cpu";
    vector<string> package_ids;
    if (file_exist(sysfs_cpu_directory)) {
        for (int i = 0; ; i++) {
            char buf[10];
            snprintf(buf, sizeof(buf) - 1, "%u", i);
            string cpu_phys_file = sysfs_cpu_directory + "/cpu" + buf + "/topology/physical_package_id";
            if (!file_exist(cpu_phys_file))
                break;

            package_ids.push_back(read_oneline_file(cpu_phys_file));
        }

        sort(begin(package_ids), end(package_ids));
        unique(begin(package_ids), end(package_ids));
        facts["physicalprocessorcount"] = to_string(package_ids.size());
    } else {
        // here's where the fall back to /proc/cpuinfo would go
    }
}

void get_processorcount_fact(fact_map& facts)
{
    ifstream cpuinfo_file("/proc/cpuinfo", ifstream::in);
    string line;
    int processor_count = 0;
    string current_processor_number;
    while (getline(cpuinfo_file, line)) {
        unsigned sep = line.find(":");
        string tmp = line.substr(0, sep);
        string key = trim(tmp);

        if (key == "processor") {
            ++processor_count;
            string tmp = line.substr(sep + 1, string::npos);
            current_processor_number = trim(tmp);
        } else if (key == "model name") {
            string tmp = line.substr(sep + 1, string::npos);
            facts[string("processor") + current_processor_number] = trim(tmp);
        }
    }
    // this was added after 1.7.3, omit for now, needs investigation
    if (false) facts["activeprocessorcount"] = processor_count;
    facts["processorcount"] = to_string(processor_count);
}

void get_processor_facts(fact_map& facts)
{
    get_physicalprocessorcount_fact(facts);
    get_processorcount_fact(facts);
}

void get_architecture_facts(fact_map& facts)
{
    utsname uts;
    if (uname(&uts) == 0) {
        // This is cheating at some level because these are all the same on x86_64 linux.
        // Otoh, some of these may be compiled-in for a C version.  And then if facter
        // relies on 'uname -p' here and that commonizes, this should perhaps just shell out
        // and not reproduce that logic. Regardless, need to survey cross-platform here and
        // take it from there.
        facts["hardwaremodel"] = uts.machine;
        facts["hardwareisa"] = uts.machine;
        facts["architecture"] = uts.machine;
    }
}

void get_dmidecode_facts(fact_map& facts)
{
    string dmidecode_output = popen_stdout("/usr/sbin/dmidecode 2> /dev/null");
    stringstream ss(dmidecode_output);
    string line;

    enum {
        bios_information,
        base_board_information,
        system_information,
        chassis_information,
        unknown
    } dmi_section = unknown;

    while (getline(ss, line)) {
        if (line.empty()) continue;

        // enable case-insensitive compares
        ci_string ci_line = line.c_str();

        // identify the dmi section, they all begin at the beginning of a line
        // and there are only a handful of interest to us
        if (ci_line == "BIOS Information") {
            dmi_section = bios_information;
            continue;
        } else if (ci_line == "Base Board Information") {
            dmi_section = base_board_information;
            continue;
        } else if (ci_line == "System Information") {
            dmi_section = system_information;
            continue;
        } else if (ci_line == "Chassis Information" || ci_line == "system enclosure or chassis") {
            dmi_section = chassis_information;
            continue;
        } else if (ci_line[0] >= 'A' && ci_line[0] <= 'Z') {
            dmi_section = unknown;
            continue;
        }

        // if we're in the middle of an unknown section, skip
        if (dmi_section == unknown) continue;

        size_t sep = line.find(":");
        if (sep != string::npos) {
            string tmp = line.substr(0, sep);
            string key = trim(tmp);
            if (dmi_section == bios_information) {
                ci_string ci_key = key.c_str();
                if (ci_key == "vendor") {
                    string tmp = line.substr(sep + 1, string::npos);
                    string value = trim(tmp);
                    facts["bios_vendor"] = value;
                }
                if (ci_key == "version") {
                    string tmp = line.substr(sep + 1, string::npos);
                    string value = trim(tmp);
                    facts["bios_version"] = value;
                }
                if (ci_key == "release date") {
                    string tmp = line.substr(sep + 1, string::npos);
                    string value = trim(tmp);
                    facts["bios_release_date"] = value;
                }
            } else if (dmi_section == base_board_information) {
                ci_string ci_key = key.c_str();
                if (ci_key == "manufacturer") {
                    string tmp = line.substr(sep + 1, string::npos);
                    string value = trim(tmp);
                    facts["boardmanufacturer"] = value;
                }
                if (ci_key == "product name" || ci_key == "product") {
                    string tmp = line.substr(sep + 1, string::npos);
                    string value = trim(tmp);
                    facts["boardproductname"] = value;
                }
                if (ci_key == "serial number") {
                    string tmp = line.substr(sep + 1, string::npos);
                    string value = trim(tmp);
                    facts["boardserialnumber"] = value;
                }
            } else if (dmi_section == system_information) {
                ci_string ci_key = key.c_str();
                if (ci_key == "manufacturer") {
                    string tmp = line.substr(sep + 1, string::npos);
                    string value = trim(tmp);
                    facts["manufacturer"] = value;
                }
                if (ci_key == "product name" || ci_key == "product") {
                    string tmp = line.substr(sep + 1, string::npos);
                    string value = trim(tmp);
                    facts["productname"] = value;
                }
                if (ci_key == "serial number") {
                    string tmp = line.substr(sep + 1, string::npos);
                    string value = trim(tmp);
                    facts["serialnumber"] = value;
                }
                if (ci_key == "uuid") {
                    string tmp = line.substr(sep + 1, string::npos);
                    string value = trim(tmp);
                    facts["uuid"] = value;
                }
            } else if (dmi_section == chassis_information) {
                ci_string ci_key = key.c_str();
                if (ci_key == "chassis type" || ci_key == "type") {
                    string tmp = line.substr(sep + 1, string::npos);
                    string value = trim(tmp);
                    facts["type"] = value;
                }
            }
        }
    }
}

void get_filesystems_facts(fact_map& facts)
{
    ifstream cpuinfo_file("/proc/filesystems", ifstream::in);
    string line;
    string filesystems = "";
    while (getline(cpuinfo_file, line)) {
        if (line.find("nodev") != string::npos || line.find("fuseblk") != string::npos)
            continue;

        if (!filesystems.empty())
            filesystems += ",";

        filesystems += trim(line);
    }
    facts["filesystems"] = filesystems;
}

void get_hostname_facts(fact_map& facts)
{
    // there's some history here, perhaps just port the facter conditional straight across?
    // so this is short-term
    string hostname_output = popen_stdout("hostname");
    unsigned sep = hostname_output.find(".");
    string hostname1 = hostname_output.substr(0, sep);
    string hostname = trim(hostname1);

    ifstream resolv_conf_file("/etc/resolv.conf", ifstream::in);
    string line;
    string domain;
    string search;
    while (getline(resolv_conf_file, line)) {
        vector<string> elems;
        tokenize(line, elems);
        if (elems.size() >= 2) {
            if (elems[0] == "domain")
                domain = trim(elems[1]);
            else if (elems[0] == "search")
                search = trim(elems[1]);
        }
    }
    if (domain.empty() && !search.empty())
        domain = search;

    facts["hostname"] = hostname;
    facts["domain"] = domain;
    facts["fqdn"] = hostname + "." + domain;
}

static void get_external_facts_from_executable(fact_map& facts, string const& executable)
{
    // executable
    FILE *stdout = popen(executable.c_str(), "r");
    if (stdout) {
        while (!feof(stdout)) {
            const int buffer_len = 32 * 1024;
            char buffer[buffer_len];
            if (fgets(buffer, buffer_len, stdout)) {
                vector<string> elems;
                split(buffer, '=', elems);
                if (elems.size() != 2) continue;  // shouldn't happen
                string key = trim(elems[0]);
                string val = trim(elems[1]);
                facts[key] = val;
            }
        }
        pclose(stdout);
    }
}

static void get_external_facts(fact_map& facts, string const& directory)
{
    DIR *external_dir = opendir(directory.c_str());
    if (!external_dir)
        return;

    dirent* external_fact;
    struct stat s;

    while ((external_fact = readdir(external_dir))) {
        string full_path = directory + "/" + external_fact->d_name;

        if (stat(full_path.c_str(), &s) != 0)
            continue;

        if (s.st_mode & S_IFDIR)
            continue;

        if (access(full_path.c_str(), X_OK) != 0)
            continue;

        get_external_facts_from_executable(facts, full_path);
    }
}

void get_external_facts(fact_map& facts, list<string> const& directories)
{
    for (auto const& dir : directories) {
        get_external_facts(facts, dir);
    }
}
