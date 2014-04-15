#ifndef LIB_INC_FACTS_LINUX_FACT_HPP_
#define LIB_INC_FACTS_LINUX_FACT_HPP_

namespace cfacter { namespace facts { namespace linux {

    /**
     * Stores the constant fact names.
     */
    struct fact
    {
        constexpr static char const* lsb_dist_id = "lsbdistid";
        constexpr static char const* lsb_dist_release = "lsbdistrelease";
        constexpr static char const* lsb_dist_codename = "lsbdistcodename";
        constexpr static char const* lsb_dist_description = "lsbdistdescription";
        constexpr static char const* lsb_dist_major_release = "lsbmajdistrelease";
        constexpr static char const* lsb_dist_minor_release = "lsbminordistrelease";
        constexpr static char const* lsb_release = "lsbrelease";
    };

}}}  // namespace cfacter::facts::linux

#endif  // LIB_INC_FACTS_LINUX_FACT_HPP_
