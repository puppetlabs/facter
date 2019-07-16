#pragma once

#include <internal/facts/linux/processor_resolver.hpp>
#include <map>
#include <functional>
#include <vector>
#include <tuple>
#include <memory>
#include <boost/filesystem.hpp>
#include <boost/optional.hpp>
#include <boost/nowide/iostream.hpp>
#include <boost/nowide/fstream.hpp>

struct linux_cpu_fixture
{
    explicit linux_cpu_fixture(boost::filesystem::path const& sys_dir, int id, std::string const& model_name);

    void set_logical_id(std::string const& logical_id);
    virtual void set_physical_id(std::string const& physical_id);
    virtual void set_speed(int64_t speed);
    void set_info(std::string const& key, std::string const& value);
    void erase_info(std::string const& key);
    void erase_all_info();
    std::string get_info();

protected:
    virtual void init_info(std::string const& model_name);

    std::map<std::string, std::string, std::function<bool(std::string const&, std::string const&)>> _info;

    boost::filesystem::path _cpuroot;
    boost::filesystem::path _topology;
    boost::filesystem::path _cpufreq;
};

struct linux_power_cpu_fixture : linux_cpu_fixture
{
    explicit linux_power_cpu_fixture(boost::filesystem::path const& sys_dir, int id, std::string const& model_name);

    virtual void set_physical_id(std::string const& physical_id) override;
    virtual void set_speed(int64_t speed) override;

protected:
    virtual void init_info(std::string const& model_name) override;
};

struct test_linux_processor_resolver : facter::facts::linux::processor_resolver
{
    using facter::facts::linux::processor_resolver::ArchitectureType;
    struct test_linux_data : facter::facts::resolvers::processor_resolver::data {};
    test_linux_data collect_cpu_data(std::string const& root);
    ArchitectureType architecture_type(test_linux_data const& data, std::string const& root);
};

struct linux_processor_fixture
{
    explicit linux_processor_fixture(std::string const& root, test_linux_processor_resolver::ArchitectureType arch_type);
    ~linux_processor_fixture();
    int add_cpu(std::string const& model_name);
    linux_cpu_fixture& get_cpu(int id);
    void write_cpuinfo();
    void add_to_sys_dir(std::string const& dir_name);
    void clear_sys_dir();
    void reset(test_linux_processor_resolver::ArchitectureType arch_type = test_linux_processor_resolver::ArchitectureType::X86);

private:
    std::vector<std::unique_ptr<linux_cpu_fixture>> _cpus;
    std::function<linux_cpu_fixture*(boost::filesystem::path const&, int, std::string const&)> make_cpu;
    int _next_id;

    boost::filesystem::path _root;
    boost::filesystem::path _proc;
    boost::filesystem::path _sys;
};

// a cpu is defined as (Model name, Logical id, Physical id, (Optional) Speed)
std::vector<int> setup_linux_processor_fixture(linux_processor_fixture& fixture, std::vector<std::tuple<std::string, std::string, std::string, boost::optional<int64_t>>> const& cpu_params);
