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

// For case-insensitive strings, define ci_string
// Thank you, Herb Sutter: http://www.gotw.ca/gotw/029.htm
//
struct ci_char_traits : public std::char_traits<char>
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

    static int compare(const char* s1,
                       const char* s2,
                       size_t n)
    {
        return strncasecmp(s1, s2, n);
        // if available on your compiler,
        //  otherwise you can roll your own
    }

    static const char*
    find(const char* s, int n, char a)
    {
        while (n-- > 0 && toupper(*s) != toupper(a)) {
            ++s;
        }
        return s;
    }
};

typedef std::basic_string<char, ci_char_traits> ci_string;

// trim from start
static inline std::string &ltrim(std::string &s)
{
    s.erase(s.begin(), std::find_if(s.begin(), s.end(), std::not1(std::ptr_fun<int, int>(std::isspace))));
    return s;
}

// trim from end
static inline std::string &rtrim(std::string &s)
{
    s.erase(std::find_if(s.rbegin(), s.rend(), std::not1(std::ptr_fun<int, int>(std::isspace))).base(), s.end());
    return s;
}

// trim from both ends
static inline std::string &trim(std::string &s)
{
    return ltrim(rtrim(s));
}

static inline void tokenize(std::string &s, std::vector<std::string> &tokens)
{
    std::istringstream iss(s);
    copy(std::istream_iterator<std::string>(iss),
         std::istream_iterator<std::string>(),
         std::back_inserter<std::vector<std::string> >(tokens));
}

static inline void split(const std::string &s, char delim, std::vector<std::string> &elems)
{
    std::stringstream ss(s);
    std::string item;
    while (getline(ss, item, delim)) {
        elems.push_back(item);
    }
}

static bool file_exist(std::string filename)
{
    struct stat buffer;
    return stat (filename.c_str(), &buffer) == 0;
}

// handy for some /proc and /sys files
std::string read_oneline_file(const std::string file_path)
{
    std::ifstream oneline_file(file_path.c_str(), std::ifstream::in);
    std::string line;
    std::getline(oneline_file, line);
    return line;
}

void get_network_facts(fact_map& facts)
{
    struct ifreq *ifr;
    struct ifconf ifc;
    int s, i;
    int numif;

    // find number of interfaces.
    memset(&ifc, 0, sizeof(ifc));
    ifc.ifc_ifcu.ifcu_req = NULL;
    ifc.ifc_len = 0;

    if ((s = socket(AF_INET, SOCK_DGRAM, 0)) < 0) {
        perror("socket");
        exit(1);
    }

    if (ioctl(s, SIOCGIFCONF, &ifc) < 0) {
        perror("ioctl");
        exit(1);
    }

    if ((ifr = static_cast<struct ifreq *>(malloc(ifc.ifc_len))) == NULL) {
        perror("malloc");
        exit(1);
    }
    ifc.ifc_ifcu.ifcu_req = ifr;

    if (ioctl(s, SIOCGIFCONF, &ifc) < 0) {
        perror("ioctl SIOCGIFCONF");
        exit(1);
    }

    std::string interfaces = "";

    bool primaryInterfacePrinted = false;
    numif = ifc.ifc_len / sizeof(struct ifreq);
    for (i = 0; i < numif; i++) {
        struct ifreq *r = &ifr[i];
        struct in_addr ip_addr = ((struct sockaddr_in *)&r->ifr_addr)->sin_addr;

        // no idea what the real algorithm is to identify the unmarked
        // interface, i.e. the one that facter reports as just 'ipaddress'
        // here just take the first one that's not 'lo'
        bool primaryInterface = false;
        if (!primaryInterfacePrinted && strcmp(r->ifr_name, "lo")) {
            // this is the chosen interface
            primaryInterface = true;
            primaryInterfacePrinted = true;
        }

        // build up 'interfaces' fact as we go, appending comma after all but last
        interfaces += r->ifr_name;
        if (i < numif - 1)
            interfaces += ",";

        const char *ipaddress = inet_ntoa(ip_addr);
        facts[std::string("ipaddress_") + r->ifr_name] = ipaddress;
        if (primaryInterface)
            facts["ipaddress"] = ipaddress;

        // mtu
        if (ioctl(s, SIOCGIFMTU, r) < 0) {
            perror("ioctl SIOCGIFMTU");
            exit(1);
        }

        facts[std::string("mtu_") + r->ifr_name] = std::to_string(r->ifr_mtu);
        if (primaryInterface) {}  // no unmarked version of this network fact

        // netmask and network are both derived from the same ioctl
        if (ioctl(s, SIOCGIFNETMASK, r) < 0) {
            perror("ioctl SIOCGIFNETMASK");
            exit(1);
        }

#ifndef __APPLE__  // ifr_netmask isn't supported, might need to use SC library
        // netmask
        struct in_addr netmask_addr = ((struct sockaddr_in *)&r->ifr_netmask)->sin_addr;
        const char *netmask = inet_ntoa(netmask_addr);
        facts[std::string("netmask_") + r->ifr_name] = netmask;
        if (primaryInterface)
            facts["netmask"] = netmask;

        // mess of casting to get the network address
        struct in_addr network_addr;
        network_addr.s_addr =
            (in_addr_t) uint32_t(netmask_addr.s_addr) & uint32_t(ip_addr.s_addr);
        std::string network = inet_ntoa(network_addr);
        facts[std::string("network_") + r->ifr_name] = network;
        if (primaryInterface)
            facts["network"] = network;
#endif

#ifndef __APPLE__  // SIOCGIFHWADDR isn't supported, might need to use SC library
        // and the mac address (but not for loopback)
        if (strcmp(r->ifr_name, "lo")) {
            if (ioctl(s, SIOCGIFHWADDR, r) < 0) {
                perror("ioctl SIOCGIFHWADDR");
                exit(1);
            }

            // extract mac into a string, okay a char array
            uint8_t *mac_bytes = reinterpret_cast<uint8_t *>((reinterpret_cast<sockaddr *>(&r->ifr_hwaddr))->sa_data);
            char mac_address[18];
            snprintf(mac_address, sizeof(mac_address),
                     "%02x:%02x:%02x:%02x:%02x:%02x",
                     mac_bytes[0], mac_bytes[1], mac_bytes[2],
                     mac_bytes[3], mac_bytes[4], mac_bytes[5]);

            // and get it out
            facts[std::string("macaddress_") + r->ifr_name] = mac_address;
            if (primaryInterface)
                facts["macaddress"] = mac_address;
        }
#endif
    }

    facts["interfaces"] = interfaces;

    close(s);
    free(ifr);
}

void get_kernel_facts(fact_map& facts)
{
#ifdef __linux__
    // this is linux-only, so there you have it
    facts["kernel"] = "Linux";
    std::string kernelrelease = read_oneline_file("/proc/sys/kernel/osrelease");
    facts["kernelrelease"] = kernelrelease;
    std::string kernelversion = kernelrelease.substr(0, kernelrelease.find("-"));
    facts["kernelversion"] = kernelversion;
    std::string kernelmajversion = kernelversion.substr(0, kernelversion.rfind("."));
    facts["kernelmajversion"] = kernelmajversion;
#else
#ifdef __APPLE__
    facts["kernel"] = "Darwin";
#endif
#endif
}

static void get_lsb_facts(fact_map& facts)
{
    std::ifstream lsb_release_file("/etc/lsb-release", std::ifstream::in);
    std::string line;
    while (std::getline(lsb_release_file, line)) {
        unsigned sep = line.find("=");
        std::string key = line.substr(0, sep);
        std::string value = line.substr(sep + 1, std::string::npos);

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
        std::string redhat_release = read_oneline_file("/etc/redhat-release");
        std::vector<std::string> tokens;
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
    std::string uptime = read_oneline_file("/proc/uptime");
    unsigned int uptime_seconds;
    sscanf(uptime.c_str(), "%ud", &uptime_seconds);
    unsigned int uptime_hours = uptime_seconds / 3600;
    unsigned int uptime_days  = uptime_hours   / 24;
    facts["uptime_seconds"] = std::to_string(uptime_seconds);
    facts["uptime_hours"] =   std::to_string(uptime_hours);
    facts["uptime_days"] =    std::to_string(uptime_days);
    facts["uptime"] =         std::to_string(uptime_days) + " days";
}

std::string popen_stdout(std::string cmd)
{
    FILE *cmd_fd = popen(cmd.c_str(), "r");
    std::string cmd_output = "";
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
    std::string blockdevices = "";

    DIR *sys_block_dir = opendir("/sys/block");
    if (sys_block_dir == NULL) {
        return;
    }

    struct dirent *bd;
    while ((bd = readdir(sys_block_dir))) {
        bool real_block_device = false;
        std::string device_dir_path = "/sys/block/";
        device_dir_path += bd->d_name;

        DIR *device_dir = opendir(device_dir_path.c_str());
        struct dirent *subdir;
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

        std::string model_file = "/sys/block/" + std::string(bd->d_name) + "/device/model";
        facts[std::string("blockdevice_") + bd->d_name + "_model"] =
            read_oneline_file(model_file);

        std::string vendor_file = "/sys/block/" + std::string(bd->d_name) + "/device/vendor";
        facts[std::string("blockdevice_") + bd->d_name + "_vendor"] =
            read_oneline_file(vendor_file);

        std::string size_file = "/sys/block/" + std::string(bd->d_name) + "/size";
        std::string size_line = read_oneline_file(size_file);
        int64_t size;
        sscanf(size_line.c_str(), "%" SCNd64, &size);
        facts[std::string("blockdevice_") + bd->d_name + "_size"] = std::to_string(size * 512);
    }

    facts["blockdevices"] = blockdevices;
}

void get_misc_facts(fact_map& facts)
{
    facts["path"] = getenv("PATH");
    std::string whoami = popen_stdout("whoami");
    facts["id"] = trim(whoami);

    // timezone
    char tzstring[16];
    time_t t = time(NULL);
    struct tm loc;
    localtime_r(&t, &loc);
    strftime(tzstring, sizeof(tzstring - 1), "%Z", &loc);
    facts["timezone"] = tzstring;
}

// get just one fact, optionally in two formats
static void get_mem_fact(std::string fact_name, int fact_value, fact_map& facts,
                         bool get_mb_variant = true)
{
    float fact_value_scaled = fact_value / 1024.0;
    char float_buf[32];

    if (get_mb_variant) {
        snprintf(float_buf, sizeof(float_buf) - 1, "%.2f", fact_value_scaled);
        facts[std::string(fact_name) + "_mb"] = float_buf;
    }

    int scale_index;
    for (scale_index = 0;
            fact_value_scaled > 1024.0;
            fact_value_scaled /= 1024.0, ++scale_index) {}

    std::string scale[4] = {"MB", "GB", "TB", "PB"};  // oh yeah, petabytes ...

    snprintf(float_buf, sizeof(float_buf) - 1, "%.2f", fact_value_scaled);
    facts[fact_name] = std::string(float_buf) + scale[scale_index];
}

void get_mem_facts(fact_map& facts)
{
    std::ifstream oneline_file("/proc/meminfo", std::ifstream::in);
    std::string line;

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

    while (std::getline(oneline_file, line)) {
        std::vector<std::string> tokens;
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

static std::string get_selinux_path()
{
    static std::string selinux_path = "";
    static bool        inited       = false;

    if (inited)
        return selinux_path;

    std::ifstream mounts("/proc/self/mounts", std::ifstream::in);
    std::string line;

    while (std::getline(mounts, line)) {
        std::vector<std::string> tokens;
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
    std::string selinux_path = get_selinux_path();
    if (selinux_path.empty())
        return false;

    std::string selinux_enforce_path = selinux_path + "/enforce";
    std::string security_attr_path   = "/proc/self/attr/current";
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

    std::string selinux_path = get_selinux_path();

    std::string selinux_enforce_path = selinux_path + "/enforce";
    if (file_exist(selinux_enforce_path))
        facts["selinux_enforced"] = ((read_oneline_file(selinux_enforce_path) == "1") ? "true" : "false");

    std::string selinux_policyvers_path = selinux_path + "/policyvers";
    if (file_exist(selinux_policyvers_path))
        facts["selinux_policyversion"] = read_oneline_file(selinux_policyvers_path);

    std::string selinux_cmd = "/usr/sbin/sestatus";
    FILE* pipe = popen(selinux_cmd.c_str(), "r");
    if (!pipe) return;

    char buffer[512];   // seems like a lot, but there's no constant available
    while (!feof(pipe)) {
        if (fgets(buffer, 128, pipe) != NULL) {
            std::vector<std::string> elems;
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

static void get_ssh_fact(std::string fact_name, std::string path_name, fact_map& facts)
{
    std::string ssh_directories[] = {
        "/etc/ssh",
        "/usr/local/etc/ssh",
        "/etc",
        "/usr/local/etc",
        "/etc/opt/ssh",
    };

    for (size_t i = 0; i < sizeof(ssh_directories) / sizeof(std::string); ++i) {
        std::string full_path = ssh_directories[i] + "/" + path_name;
        if (file_exist(full_path)) {
            std::string key = read_oneline_file(full_path);
            std::vector<std::string> tokens;
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
    // not til C++11 do we have static initialization of stl maps
    std::map<std::string, std::string> ssh_facts;
    ssh_facts["sshdsakey"] = "ssh_host_dsa_key.pub";
    ssh_facts["sshrsakey"] = "ssh_host_rsa_key.pub";
    ssh_facts["sshecdsakey"] = "ssh_host_ecdsa_key.pub";

    for (auto i = ssh_facts.begin(); i != ssh_facts.end(); ++i) {
        get_ssh_fact(i->first, i->second, facts);
    }
}

static void get_physicalprocessorcount_fact(fact_map& facts)
{
    // So, facter has logic to use /sys and fallback to /proc
    // but I don't know why the /sys support was added; research needed.
    // Since sys is the default, just reproduce that logic for now.

    std::string sysfs_cpu_directory = "/sys/devices/system/cpu";
    std::vector<std::string> package_ids;
    if (file_exist(sysfs_cpu_directory)) {
        for (int i = 0; ; i++) {
            char buf[10];
            snprintf(buf, sizeof(buf) - 1, "%u", i);
            std::string cpu_phys_file = sysfs_cpu_directory + "/cpu" + buf + "/topology/physical_package_id";
            if (!file_exist(cpu_phys_file))
                break;

            package_ids.push_back(read_oneline_file(cpu_phys_file));
        }

        sort(package_ids.begin(), package_ids.end());
        unique(package_ids.begin(), package_ids.end());
        facts["physicalprocessorcount"] = std::to_string(package_ids.size());
    } else {
        // here's where the fall back to /proc/cpuinfo would go
    }
}

void get_processorcount_fact(fact_map& facts)
{
    std::ifstream cpuinfo_file("/proc/cpuinfo", std::ifstream::in);
    std::string line;
    int processor_count = 0;
    std::string current_processor_number;
    while (std::getline(cpuinfo_file, line)) {
        unsigned sep = line.find(":");
        std::string tmp = line.substr(0, sep);
        std::string key = trim(tmp);

        if (key == "processor") {
            ++processor_count;
            std::string tmp = line.substr(sep + 1, std::string::npos);
            current_processor_number = trim(tmp);
        } else if (key == "model name") {
            std::string tmp = line.substr(sep + 1, std::string::npos);
            facts[std::string("processor") + current_processor_number] = trim(tmp);
        }
    }
    // this was added after 1.7.3, omit for now, needs investigation
    if (false) facts["activeprocessorcount"] = processor_count;
    facts["processorcount"] = std::to_string(processor_count);
}

void get_processor_facts(fact_map& facts)
{
    get_physicalprocessorcount_fact(facts);
    get_processorcount_fact(facts);
}

void get_architecture_facts(fact_map& facts)
{
    struct utsname uts;
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
    std::string dmidecode_output = popen_stdout("/usr/sbin/dmidecode 2> /dev/null");
    std::stringstream ss(dmidecode_output);
    std::string line;

    enum {
        bios_information,
        base_board_information,
        system_information,
        chassis_information,
        unknown
    } dmi_section = unknown;

    while (std::getline(ss, line)) {
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
        if (sep != std::string::npos) {
            std::string tmp = line.substr(0, sep);
            std::string key = trim(tmp);
            if (dmi_section == bios_information) {
                ci_string ci_key = key.c_str();
                if (ci_key == "vendor") {
                    std::string tmp = line.substr(sep + 1, std::string::npos);
                    std::string value = trim(tmp);
                    facts["bios_vendor"] = value;
                }
                if (ci_key == "version") {
                    std::string tmp = line.substr(sep + 1, std::string::npos);
                    std::string value = trim(tmp);
                    facts["bios_version"] = value;
                }
                if (ci_key == "release date") {
                    std::string tmp = line.substr(sep + 1, std::string::npos);
                    std::string value = trim(tmp);
                    facts["bios_release_date"] = value;
                }
            } else if (dmi_section == base_board_information) {
                ci_string ci_key = key.c_str();
                if (ci_key == "manufacturer") {
                    std::string tmp = line.substr(sep + 1, std::string::npos);
                    std::string value = trim(tmp);
                    facts["boardmanufacturer"] = value;
                }
                if (ci_key == "product name" || ci_key == "product") {
                    std::string tmp = line.substr(sep + 1, std::string::npos);
                    std::string value = trim(tmp);
                    facts["boardproductname"] = value;
                }
                if (ci_key == "serial number") {
                    std::string tmp = line.substr(sep + 1, std::string::npos);
                    std::string value = trim(tmp);
                    facts["boardserialnumber"] = value;
                }
            } else if (dmi_section == system_information) {
                ci_string ci_key = key.c_str();
                if (ci_key == "manufacturer") {
                    std::string tmp = line.substr(sep + 1, std::string::npos);
                    std::string value = trim(tmp);
                    facts["manufacturer"] = value;
                }
                if (ci_key == "product name" || ci_key == "product") {
                    std::string tmp = line.substr(sep + 1, std::string::npos);
                    std::string value = trim(tmp);
                    facts["productname"] = value;
                }
                if (ci_key == "serial number") {
                    std::string tmp = line.substr(sep + 1, std::string::npos);
                    std::string value = trim(tmp);
                    facts["serialnumber"] = value;
                }
                if (ci_key == "uuid") {
                    std::string tmp = line.substr(sep + 1, std::string::npos);
                    std::string value = trim(tmp);
                    facts["uuid"] = value;
                }
            } else if (dmi_section == chassis_information) {
                ci_string ci_key = key.c_str();
                if (ci_key == "chassis type" || ci_key == "type") {
                    std::string tmp = line.substr(sep + 1, std::string::npos);
                    std::string value = trim(tmp);
                    facts["type"] = value;
                }
            }
        }
    }
}

void get_filesystems_facts(fact_map& facts)
{
    std::ifstream cpuinfo_file("/proc/filesystems", std::ifstream::in);
    std::string line;
    std::string filesystems = "";
    while (std::getline(cpuinfo_file, line)) {
        if (line.find("nodev") != std::string::npos || line.find("fuseblk") != std::string::npos)
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
    std::string hostname_output = popen_stdout("hostname");
    unsigned sep = hostname_output.find(".");
    std::string hostname1 = hostname_output.substr(0, sep);
    std::string hostname = trim(hostname1);

    std::ifstream resolv_conf_file("/etc/resolv.conf", std::ifstream::in);
    std::string line;
    std::string domain;
    std::string search;
    while (std::getline(resolv_conf_file, line)) {
        std::vector<std::string> elems;
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

static void get_external_facts_from_executable(fact_map& facts, std::string executable)
{
    // executable
    FILE *stdout = popen(executable.c_str(), "r");
    if (stdout) {
        while (!feof(stdout)) {
            const int buffer_len = 32 * 1024;
            char buffer[buffer_len];
            if (fgets(buffer, buffer_len, stdout)) {
                std::vector<std::string> elems;
                split(buffer, '=', elems);
                if (elems.size() != 2) continue;  // shouldn't happen
                std::string key = trim(elems[0]);
                std::string val = trim(elems[1]);
                facts[key] = val;
            }
        }
        pclose(stdout);
    }
}

static void get_external_facts(fact_map& facts, std::string directory)
{
    DIR *external_dir = opendir(directory.c_str());
    if (external_dir == NULL)
        return;

    struct dirent *external_fact;
    struct stat s;

    while ((external_fact = readdir(external_dir))) {
        std::string full_path = directory + "/" + external_fact->d_name;

        if (stat(full_path.c_str(), &s) != 0)
            continue;

        if (s.st_mode & S_IFDIR)
            continue;

        if (access(full_path.c_str(), X_OK) != 0)
            continue;

        get_external_facts_from_executable(facts, full_path);
    }
}

void get_external_facts(fact_map& facts, const std::list<std::string>& directories)
{
    for (auto iter = directories.begin(); iter != directories.end(); ++iter) {
        get_external_facts(facts, *iter);
    }
}
