#include <dirent.h>
#include <inttypes.h>
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <string.h>
#include <sys/ioctl.h>
#include <sys/socket.h>
#include <sys/types.h>
#include <sys/utsname.h>
#include <linux/if.h>
#include <netinet/in.h>
#include <arpa/inet.h>
#include <sys/stat.h>

#include <algorithm>
#include <fstream>
#include <iostream>
#include <iomanip>
#include <map>
#include <string>
#include <sstream>
#include <vector>
#include <iterator>

#include "cfacterlib.h"

using namespace std;

// trim from start
static inline std::string &ltrim(std::string &s) {
    s.erase(s.begin(), std::find_if(s.begin(), s.end(), std::not1(std::ptr_fun<int, int>(std::isspace))));
    return s;
}

// trim from end
static inline std::string &rtrim(std::string &s) {
    s.erase(std::find_if(s.rbegin(), s.rend(), std::not1(std::ptr_fun<int, int>(std::isspace))).base(), s.end());
    return s;
}

// trim from both ends
static inline std::string &trim(std::string &s) {
    return ltrim(rtrim(s));
}

static inline void tokenize(std::string &s, vector<string> &tokens) {
    istringstream iss(s);
    copy(istream_iterator<string>(iss),
	 istream_iterator<string>(),
	 back_inserter<vector<string> >(tokens));
}

static inline void split(const string &s, char delim, vector<string> &elems) {
  stringstream ss(s);
  string item;
  while (getline(ss, item, delim)) {
    elems.push_back(item);
  }
}

static bool file_exist (string filename)
{
  struct stat buffer;
  return stat (filename.c_str(), &buffer) == 0;
}

// handy for some /proc and /sys files
string read_oneline_file(const string file_path)
{
    std::ifstream oneline_file(file_path.c_str(), std::ifstream::in);
    std::string line;
    std::getline(oneline_file, line);
    return line;
}

void dump_network_facts()
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

   string interfaces = "";

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
     cout << "ipaddress_" << r->ifr_name << " => " << ipaddress << endl;
     if (primaryInterface)
         cout << "ipaddress => " << ipaddress << endl;

     // mtu
     if (ioctl(s, SIOCGIFMTU, r) < 0) {
         perror("ioctl SIOCGIFMTU");
         exit(1);
     }

     cout << "mtu_" << r->ifr_name << " => " << r->ifr_mtu << endl;
     if (primaryInterface) ; // no unmarked version of this network fact
     
     // netmask and network are both derived from the same ioctl
     if (ioctl(s, SIOCGIFNETMASK, r) < 0) {
         perror("ioctl SIOCGIFNETMASK");
         exit(1);
     }

     // netmask
     struct in_addr netmask_addr = ((struct sockaddr_in *)&r->ifr_netmask)->sin_addr;
     const char *netmask = inet_ntoa(netmask_addr);
     cout << "netmask_" << r->ifr_name << " => " << netmask << endl;
     if (primaryInterface)
         cout << "netmask => " << netmask << endl;

     // mess of casting to get the network address
     struct in_addr network_addr;
     network_addr.s_addr =
         (in_addr_t) uint32_t(netmask_addr.s_addr) & uint32_t(ip_addr.s_addr);
     string network = inet_ntoa(network_addr);
     cout << "network_" << r->ifr_name << " => " << network << endl;
     if (primaryInterface)
         cout << "network => " << network << endl;

     // and the mac address (but not for loopback)
     if (strcmp(r->ifr_name, "lo")) {
         if (ioctl(s, SIOCGIFHWADDR, r) < 0) {
             perror("ioctl SIOCGIFHWADDR");
             exit(1);
         }

         // extract mac into a string, okay a char array
         uint8_t *mac_bytes = (uint8_t *)((sockaddr *)&r->ifr_hwaddr)->sa_data;
         char mac_address[18];
         sprintf(mac_address, "%02x:%02x:%02x:%02x:%02x:%02x",
                 mac_bytes[0], mac_bytes[1], mac_bytes[2],
                 mac_bytes[3], mac_bytes[4], mac_bytes[5]);

         // and dump it out
         cout << "macaddress_" << r->ifr_name << " => " << mac_address << endl;
         if (primaryInterface)
             cout << "macaddress => " << mac_address << endl;
     }
   }

   cout << "interfaces => " << interfaces << endl;

   close(s);
   free(ifr);
}

void dump_kernel_facts()
{
    // this is linux-only, so there you have it
    cout << "kernel => Linux" << endl;
    string kernelrelease = read_oneline_file("/proc/sys/kernel/osrelease");
    cout << "kernelrelease => " << kernelrelease << endl;
    string kernelversion = kernelrelease.substr(0, kernelrelease.find("-"));
    cout << "kernelversion => " << kernelversion << endl;
    string kernelmajversion = kernelversion.substr(0, kernelversion.rfind("."));
    cout << "kernelmajversion => " << kernelmajversion << endl;
}

static void dump_lsb_facts()
{
    std::ifstream lsb_release_file("/etc/lsb-release", std::ifstream::in);
    std::string line;
    while (std::getline(lsb_release_file, line)) {
        unsigned sep = line.find("=");
        string key = line.substr(0, sep);
        string value = line.substr(sep + 1, string::npos);
        
        if (key == "DISTRIB_ID") {
            cout << "lsbdistid => " << value << endl;
            cout << "operatingsystem => " << value << endl;
            cout << "osfamily => Debian" << endl;
        }
        else if (key == "DISTRIB_RELEASE") {
            cout << "lsbdistrelease => " << value << endl;
            cout << "operatingsystemrelease => " << value << endl;
            cout << "lsbmajdistrelease => " << value.substr(0, value.find(".")) << endl;
        }
        else if (key == "DISTRIB_CODENAME")
            cout << "lsbdistcodename => " << value << endl;
        else if (key == "DISTRIB_DESCRIPTION")
            cout << "lsbdistdescription => " << value << endl;
    }
}

// gonna need to pick a regex library to do os facts rights given all the variants
// for now, just fedora ;>

static void dump_redhat_facts()
{
  if (file_exist("/etc/redhat-release")) {
    cout << "osfamily => RedHat" << endl;
    string redhat_release = read_oneline_file("/etc/redhat-release");
    vector<string> tokens;
    tokenize(redhat_release, tokens);
    if (tokens.size() >= 2 && tokens[0] == "Fedora" && tokens[1] == "release") {
      cout << "operatingsystem => Fedora" << endl;
      if (tokens.size() >= 3) {
	cout << "operatingsystemrelease => " << tokens[2] << endl;
	cout << "operatingsystemmajrelease => " << tokens[2] << endl;
      }
    }
    else
      cout << "operatingsystem => RedHat" << endl;
  }
}

void dump_operatingsystem_facts()
{
  dump_lsb_facts();
  dump_redhat_facts();
}

void dump_uptime_facts()
{
    string uptime = read_oneline_file("/proc/uptime");
    unsigned int uptime_seconds;
    sscanf(uptime.c_str(), "%ud", &uptime_seconds);
    unsigned int uptime_hours = uptime_seconds / 3600;
    unsigned int uptime_days  = uptime_hours   / 24;
    cout << "uptime_seconds => " << uptime_seconds << endl;
    cout << "uptime_hours => "   << uptime_hours   << endl;
    cout << "uptime_days => "    << uptime_days    << endl;
    cout << "uptime => " << uptime_days << " days" << endl;
}

string popen_stdout(string cmd)
{
    FILE *cmd_fd = popen(cmd.c_str(), "r");
    string cmd_output = "";
    char buf[1024];
    size_t bytesRead;
    while (bytesRead = fread(buf, 1, sizeof(buf) - 1, cmd_fd)) {
        buf[bytesRead] = 0;
        cmd_output += buf;
    }
    return cmd_output;
}

void dump_virtual_facts()
{
    // poked at the real facter's virtual support, some combo of file existence
    // plus lspci plus dmidecode

    // from a time perspective simulate expense with lspci and dmidecode invocations
    string lspci_output     = popen_stdout("lspci");
    string dmidecode_output = popen_stdout("dmidecode");
    std::stringstream ss(dmidecode_output);
    string dmidecode_line;
    while (std::getline(ss, dmidecode_line)) {
        size_t sep = dmidecode_line.find(":");
        if (sep != string::npos) {
            string key = dmidecode_line.substr(0, sep);
            string value = dmidecode_line.substr(sep + 1, string::npos);
            if (key.find("UUID") != string::npos)
                cout << "uuid => " << trim(value) << endl;
        }
    }

    // instead of parsing all of lspci, how about looking for vendors in lspci -n?
    // or walking the /sys/bus/pci/devices files.  or don't sweat it, the total 
    // lspci time is ~40 ms.

    cout << "is_virtual => false" << endl;
    cout << "virtual => physical" << endl;

}

// placeholders for some hardwired facts, cuz not sure what to do with them
void dump_hardwired_facts()
{
    cout << "ps => ps -ef" << endl;  // what is this?
    cout << "uniqueid => 007f0101" << endl;  // ??
}


// versions of things we don't have if we're not running ruby
// omit or 'undef' or ...?  for now, omit but collect them here
void dump_ruby_lib_versions()
{
/*
    cout << "puppetversion => undef" << endl;
    cout << "augeasversion => undef" << endl;
    cout << "rubysitedir => undef" << endl;
    cout << "rubyversion => undef" << endl;
*/
}

// block devices
void dump_blockdevice_facts()
{
    string blockdevices = "";
    DIR *sys_block_dir = opendir("/sys/block");
    struct dirent *bd;

    while (bd = readdir(sys_block_dir)) {
        bool real_block_device = false;
        string device_dir_path = "/sys/block/";
        device_dir_path += bd->d_name;

        DIR *device_dir = opendir(device_dir_path.c_str());
        struct dirent *subdir;
        while (subdir = readdir(device_dir)) {
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
        cout << "blockdevice_" << bd->d_name << "_model => " <<
            read_oneline_file(model_file) << endl;

        string vendor_file = "/sys/block/" + string(bd->d_name) + "/device/vendor";
        cout << "blockdevice_" << bd->d_name << "_vendor => " <<
            read_oneline_file(vendor_file) << endl;

        string size_file = "/sys/block/" + string(bd->d_name) + "/size";
        string size_line = read_oneline_file(size_file);
        int64_t size;
        // SCNd64 didn't work here??
        sscanf(size_line.c_str(), "%lld", (long long int *)&size);
        cout << "blockdevice_" << bd->d_name << "_size => " << size * 512 << endl;
    }

    cout << "blockdevices => " << blockdevices << endl;
}

void dump_misc_facts()
{
    cout << "path => " << getenv("PATH") << endl;
    string whoami = popen_stdout("whoami");
    cout << "id => " << trim(whoami) << endl;

    // timezone
    //char tzstring[16];
    ////time_t here_and_now;
    ////strftime(tzstring, sizeof(tzstring - 1), "%Z", localtime(here_and_now));
}

// dump just one fact, optionally in two formats
static void dump_mem_fact(std::string fact_name, int fact_value, bool dump_mb_variant = true)
{
  float fact_value_scaled = fact_value / 1024.0;
  
  if (dump_mb_variant) {
    cout << fact_name << "_mb => " << fixed << setprecision(2) << fact_value_scaled << endl;
  }

  int scale_index;
  for (scale_index = 0;
       fact_value_scaled > 1024.0;
       fact_value_scaled /= 1024.0, ++scale_index) ;
     
  std::string scale[4] = {"MB", "GB", "TB", "PB"};  // oh yeah, petabytes ...

  cout << fact_name << " => " << fixed << setprecision(2) << fact_value_scaled << scale[scale_index] << endl;
}

void dump_mem_facts()
{
    std::ifstream oneline_file("/proc/meminfo", std::ifstream::in);
    std::string line;

    // The MemFree fact is the sum of MemFree + Buffer + Cached from /proc/meninfo,
    // so sum that one as we go, and dump it out at the end.
    // The other three memory facts are straight from /proc/meminfo, so dump those
    // as we go.
    // All four facts are dumped in two formats:
    //   <fact>_mb => %.2f
    //   <fact>  => %.2f %s  (where the suffix string is one of MB/GB/TB)
    // And then there is a ninth fact, 'memorytotal', which is the same as 'memorysize'.
    //

    // NB: this all assumes that all values are in KB.

    unsigned int memoryfree = 0;

    while (std::getline(oneline_file, line)) {
        vector<string> tokens;
        tokenize(line, tokens);
        if (tokens.size() < 3) continue;  // should never happen

        if (tokens[0] == "MemTotal:") {
	  int mem_total = atoi(tokens[1].c_str());
	  dump_mem_fact("memorysize", mem_total);
          dump_mem_fact("memorytotal", mem_total, false);
        }
        else if (tokens[0] == "MemFree:" || tokens[0] == "Cached:" || tokens[0] == "Buffers:") {
          memoryfree += atoi(tokens[1].c_str());
	}
        else if (tokens[0] == "SwapTotal:")
	  dump_mem_fact("swapsize", atoi(tokens[1].c_str()));
        else if (tokens[0] == "SwapFree:")
          dump_mem_fact("swapfree", atoi(tokens[1].c_str()));
    }

    dump_mem_fact("memoryfree", memoryfree);
}

static string get_selinux_path()
{
  static string selinux_path = "";
  static bool   inited       = false;

  if (inited)
    return selinux_path;

  std::ifstream mounts("/proc/self/mounts", std::ifstream::in);
  std::string line;

  while (std::getline(mounts, line)) {
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
  if (file_exist(selinux_enforce_path) && file_exist(security_attr_path) && read_oneline_file(security_attr_path) != "kernel")
    return true;

  return false;
}

void dump_selinux_facts()
{
  if (!selinux()) {
    cout << "selinux => false" << endl;
    return;
  }

  map<string, string> selinux_map;
  selinux_map["selinux"] = "true";

  // defaults from facter
  selinux_map["selinux_enforced"] = "false";
  selinux_map["selinux_policyversion"] = "unknown";
  selinux_map["selinux_current_mode"] = "unknown";
  selinux_map["selinux_config_mode"] = "unknown";
  selinux_map["selinux_config_policy"] = "unknown";
  selinux_map["selinux_mode"] = "unknown";

  string selinux_path = get_selinux_path();

  string selinux_enforce_path = selinux_path + "/enforce";
  if (file_exist(selinux_enforce_path))
    selinux_map["selinux_enforced"] = ((read_oneline_file(selinux_enforce_path) == "1") ? "true" : "false");

  string selinux_policyvers_path = selinux_path + "/policyvers";
  if (file_exist(selinux_policyvers_path))
    selinux_map["selinux_policyversion"] = read_oneline_file(selinux_policyvers_path);

  string selinux_cmd = "/usr/sbin/sestatus";
  FILE* pipe = popen(selinux_cmd.c_str(), "r");
  if (!pipe) return;

  char buffer[512];   // seems like a lot, but there's no constant available
  while (!feof(pipe)) {
    if (fgets(buffer, 128, pipe) != NULL) {
      vector<string> elems;
      split(buffer, ':', elems);
      if (elems.size() < 2) continue;  // shouldn't happen
      if (elems[0] == "Current mode") {
	selinux_map["selinux_current_mode"] = trim(elems[1]);
      }
      else if (elems[0] == "Mode from config file") {
	selinux_map["selinux_config_mode"] = trim(elems[1]);
      }
      else if (elems[0] == "Policy from config file") {
	selinux_map["selinux_config_policy"] = trim(elems[1]);
	selinux_map["selinux_mode"] = trim(elems[1]);
      }
    }
  }

  pclose(pipe);

  typedef map<string, string>::iterator iter;
  for (iter i = selinux_map.begin(); i != selinux_map.end(); ++i) {
    cout << i->first << " => " << i->second << endl;
  }
}

static void dump_ssh_fact(string fact_name, string path_name)
{
  string ssh_directories[] = {
    "/etc/ssh",
    "/usr/local/etc/ssh",
    "/etc",
    "/usr/local/etc",
    "/etc/opt/ssh",
  };

  for (int i = 0; i < sizeof(ssh_directories) / sizeof(string); ++i) {
    string full_path = ssh_directories[i] + "/" + path_name;
    if (file_exist(full_path)) {
      string key = read_oneline_file(full_path);
      vector<string> tokens;
      tokenize(trim(key), tokens);
      if (tokens.size() < 2) continue;  // should never happen
      cout << fact_name << " => " << tokens[1] << endl;
      break;
    }
  }
}

// no support for the sshfp facts, which require base64/sha1sum code
void dump_ssh_facts()
{
  // not til C++11 do we have static initialization of stl maps
  map<string, string> fact_map;
  fact_map["sshdsakey"] = "ssh_host_dsa_key.pub";
  fact_map["sshrsakey"] = "ssh_host_rsa_key.pub";
  fact_map["sshecdsakey"] = "ssh_host_ecdsa_key.pub";

  typedef map<string, string>::iterator iter;
  for (iter i = fact_map.begin(); i != fact_map.end(); ++i) {
    dump_ssh_fact(i->first, i->second);
  }
}
