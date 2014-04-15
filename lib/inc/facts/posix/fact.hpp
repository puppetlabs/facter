#ifndef LIB_INC_FACTS_POSIX_FACT_HPP_
#define LIB_INC_FACTS_POSIX_FACT_HPP_

namespace cfacter { namespace facts { namespace posix {

    /**
     * Stores the constant fact names.
     */
    struct fact
    {
        constexpr static char const* kernel = "kernel";
        constexpr static char const* kernel_version = "kernelversion";
        constexpr static char const* kernel_release = "kernelrelease";
        constexpr static char const* kernel_major_release = "kernelmajrelease";
        constexpr static char const* operating_system = "operatingsystem";
        constexpr static char const* os_family = "osfamily";
        constexpr static char const* operating_system_release = "operatingsystemrelease";
        constexpr static char const* operating_system_major_release = "operatingsystemmajrelease";
    };

}}}  // namespace cfacter::facts::posix

#endif  // LIB_INC_FACTS_POSIX_FACT_HPP_
