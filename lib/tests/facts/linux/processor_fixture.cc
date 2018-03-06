#include "processor_fixture.hpp"
#include <boost/algorithm/string/join.hpp>
#include <algorithm>
#include <array>
#include <sstream>

using namespace std;
using key_cmp = std::function<bool(std::string const&, std::string const&)>; 
using architecture_type = test_linux_processor_resolver::ArchitectureType; 
namespace fs = boost::filesystem;

static void reset_directory(fs::path const& path)
{
    fs::remove_all(path);
    fs::create_directories(path);
}

template <typename T>
static void write_value(boost::filesystem::path const& path, T const& value) {
  boost::nowide::ofstream ofs(path.string()); 
  ofs << value;
}

template <typename container>
static int key_index(const container& keys, const std::string& key)
{
    return find(keys.begin(), keys.end(), key) - keys.begin();
}

static key_cmp default_cpu_info_key_cmp = [](const std::string& k1, const std::string& k2)
{
    static array<string, 8> KEYS = {
      "processor",
      "vendor_id",
      "cpu_family",
      "model",
      "model name",
      "stepping",
      "microcode",
      "physical id"
    };
  
    return key_index(KEYS, k1) < key_index(KEYS, k2);
};

static key_cmp power_cpu_info_key_cmp = [](const std::string& k1, const std::string& k2)
{
    static array<string, 4> KEYS = {
      "processor",
      "cpu",
      "clock",
      "revision"
    };
  
    return key_index(KEYS, k1) < key_index(KEYS, k2);
};

linux_cpu_fixture::linux_cpu_fixture(boost::filesystem::path const& sys_dir, int id, std::string const& model_name)
{
    _cpuroot = sys_dir / ("cpu" + to_string(id));
    fs::create_directory(_cpuroot);

    _topology = _cpuroot / "topology";
    fs::create_directory(_topology);

    _cpufreq = _cpuroot / "cpufreq";
    fs::create_directory(_cpufreq);

    init_info(model_name);
}

void linux_cpu_fixture::set_logical_id(std::string const& logical_id)
{
    _info["processor"] = logical_id;
}

void linux_cpu_fixture::set_physical_id(std::string const& physical_id)
{
    write_value(_topology / "physical_package_id", physical_id);  
    _info["physical id"] = physical_id;
}

void linux_cpu_fixture::set_speed(int64_t speed)
{
    write_value(_cpufreq / "cpuinfo_max_freq", speed);  
}

void linux_cpu_fixture::set_info(std::string const& key, std::string const& value)
{
    _info[key] = value;
}

void linux_cpu_fixture::erase_info(std::string const& key)
{
    _info.erase(key);
}

void linux_cpu_fixture::erase_all_info()
{
    _info = map<string, string, key_cmp>(default_cpu_info_key_cmp);
}

std::string linux_cpu_fixture::get_info()
{
    ostringstream buf;
    for (auto& entry : _info) {
        buf << entry.first << "    :    " << entry.second << endl; 
    }
    return buf.str();
}

void linux_cpu_fixture::init_info(std::string const& model_name)
{
    _info = map<string, string, key_cmp>(default_cpu_info_key_cmp);

    _info["vendor_id"] = "GenuineIntel"; 
    _info["cpu_family"] = "6"; 
    _info["model"] = "69"; 
    _info["model name"] = model_name; 
    _info["stepping"] = "1"; 
    _info["microcode"] = "0x17"; 
}


linux_power_cpu_fixture::linux_power_cpu_fixture(boost::filesystem::path const& sys_dir, int id, std::string const& model_name)
  : linux_cpu_fixture(sys_dir, id, model_name)
{
    // what's called in the base class is not the right "init_info" method, so
    // need to call this again.
    init_info(model_name);
}

void linux_power_cpu_fixture::set_physical_id(std::string const& physical_id)
{
    linux_cpu_fixture::set_physical_id(physical_id);

    // Power's /proc/cpuinfo file does not have physical id entries
    // so we need to erase the one written in the base class
   erase_info("physical id");
}

void linux_power_cpu_fixture::set_speed(int64_t speed)
{
    linux_cpu_fixture::set_speed(speed); 
    _info["clock"] = to_string(speed) + "MHz";
}

void linux_power_cpu_fixture::init_info(std::string const& model_name)
{
    _info = map<string, string, key_cmp>(power_cpu_info_key_cmp);

    _info["cpu"] = model_name; 
    _info["revision"] = "2.1 (pvr 004b 0201)"; 
}


linux_processor_fixture::linux_processor_fixture(std::string const& root, test_linux_processor_resolver::ArchitectureType arch_type)
  : _next_id(0), _root(fs::path(root))
{
    fs::create_directory(_root);

    _proc = _root / "proc";
    _sys = _root / "sys" / "devices" / "system" / "cpu";

    reset(arch_type);
}

linux_processor_fixture::~linux_processor_fixture()
{
    fs::remove_all(_root);
}

int linux_processor_fixture::add_cpu(std::string const& model_name)
{
    _cpus.push_back(unique_ptr<linux_cpu_fixture>(make_cpu(_sys, _next_id, model_name))); 
    return _next_id++;
}

linux_cpu_fixture& linux_processor_fixture::get_cpu(int id)
{
    return *(_cpus[id]);
}

void linux_processor_fixture::write_cpuinfo()
{
    vector<string> cpu_infos;
    for (auto& cpu : _cpus) {
        cpu_infos.push_back(cpu->get_info());
    }

    write_value(_proc / "cpuinfo", boost::algorithm::join(cpu_infos, "\n\n"));
}

void linux_processor_fixture::add_to_sys_dir(std::string const& dir_name)
{
    fs::create_directory(_sys / dir_name); 
}

void linux_processor_fixture::clear_sys_dir()
{
    reset_directory(_sys);
}

void linux_processor_fixture::reset(test_linux_processor_resolver::ArchitectureType arch_type)
{
   clear_sys_dir();
   reset_directory(_proc);

   _cpus = std::vector<std::unique_ptr<linux_cpu_fixture>>();
   _next_id = 0;

    make_cpu = [arch_type](fs::path const& sys_dir, int id, std::string const& model_name) {
        return (arch_type == architecture_type::X86) ?
            new linux_cpu_fixture(sys_dir, id, model_name)
        :   new linux_power_cpu_fixture(sys_dir, id, model_name);
 
    };
}


test_linux_processor_resolver::test_linux_data test_linux_processor_resolver::collect_cpu_data(std::string const& root)
{
    test_linux_data data;
    add_cpu_data(data, root);
    return data; 
}

test_linux_processor_resolver::ArchitectureType test_linux_processor_resolver::architecture_type(test_linux_data const& data, std::string const& root)
{
    return facter::facts::linux::processor_resolver::architecture_type(data, root);
}

std::vector<int> setup_linux_processor_fixture(linux_processor_fixture& fixture, std::vector<std::tuple<std::string, std::string, std::string, boost::optional<int64_t>>> const& cpu_params)
{
    std::vector<int> ids;

    for (auto& cpu_param : cpu_params) {
        auto& model_name = get<0>(cpu_param);   
        auto& logical_id = get<1>(cpu_param);
        auto& physical_id = get<2>(cpu_param);
        auto& speed = get<3>(cpu_param);

        int id = fixture.add_cpu(model_name);
        auto& cpu = fixture.get_cpu(id);
        cpu.set_logical_id(logical_id);
        cpu.set_physical_id(physical_id);
        if (speed) {
            cpu.set_speed(speed.get());
        }
        ids.push_back(id);
    }

    // create garbage directories to ensure that only the cpu<x> directories
    // are checked, where x >= 0
    fixture.add_to_sys_dir("cpuabc");
    fixture.add_to_sys_dir("cpugarbage");

    return ids;
}
