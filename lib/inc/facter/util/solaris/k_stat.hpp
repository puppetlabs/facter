/**
 * @file
 * Declares the k_stat resource.
 */
#pragma once

#include "scoped_kstat.hpp"
#include <vector>
#include <string>

namespace facter { namespace util { namespace solaris {

    /**
     * Wrapper around the kstat_t structure.
     */
    struct k_stat_entry
    {
        /**
         * Default constructor. Should be created only by k_stat[] call.
         * @param kp The kstat_t pointer we wrap.
         *
         */
        k_stat_entry(kstat_t* kp);

        /**
         * Get a value out of our kstat_named_t
         * @param attrib The attribute we are looking up
         * @tparam T the datatype of the attribute result
         * @return Returns the looked up value.
         */
        template <typename T>
        T value(const std::string& attrib) const;

        /**
         * Gets the name of the entry.
         * @return Returns the name of entry.
         */
        std::string name();

        /**
         * Gets the class of the entry.
         * @return Returns the class of entry.
         */
        std::string klass();

        /**
         * Gets the module of the entry.
         * @return Returns the module of entry.
         */
        std::string module();

        /**
         * Gets the instance of the entry.
         * @return Returns the instance of entry.
         */
        int instance();

     private:
        /**
         * Lookup the given attribute in the kstat structure.
         * @param attrib The attribute we are looking up
         * @return Returns the looked up value.
         */
        kstat_named_t* lookup(const std::string& attrib) const;

        /**
         * Lookup the given attribute in the kstat structure, and verify that
         * the datatype is correct.
         * @param datatype The datatype of attribute we are looking up
         * @param attrib The attribute we are looking up
         * @return Returns the looked up value.
         */
        kstat_named_t* lookup(const int datatype, const std::string& attrib) const;

       /**
         * The main data in the struct, obtained by a lookup
         */
        kstat_t* k_stat;
    };

    /**
     * The template specializations for k_stat_entry::value with ulong_t.
     * @param attrib The attribute we are looking up.
     * @return Returns the looked up value.
     */
    template<>
    ulong_t k_stat_entry::value(const std::string& attrib) const;

    /**
     * The template specializations for k_stat_entry::value with long.
     * @param attrib The attribute we are looking up.
     * @return Returns the looked up value.
     */
    template<>
    long k_stat_entry::value(const std::string& attrib) const;

    /**
     * The template specializations for k_stat_entry::value with int32_t.
     * @param attrib The attribute we are looking up.
     * @return Returns the looked up value.
     */
    template<>
    int32_t k_stat_entry::value(const std::string& attrib) const;

    /**
     * The template specializations for k_stat_entry::value with uint32_t.
     * @param attrib The attribute we are looking up.
     * @return Returns the looked up value.
     */
    template<>
    uint32_t k_stat_entry::value(const std::string& attrib) const;

    /**
     * The template specializations for k_stat_entry::value with int64_t.
     * @param attrib The attribute we are looking up.
     * @return Returns the looked up value.
     */
    template<>
    int64_t k_stat_entry::value(const std::string& attrib) const;

    /**
     * The template specializations for k_stat_entry::value with uint64_t.
     * @param attrib The attribute we are looking up.
     * @return Returns the looked up value.
     */
    template<>
    uint64_t k_stat_entry::value(const std::string& attrib) const;

    /**
     * The template specializations for k_stat_entry::value with string.
     * @param attrib The attribute we are looking up.
     * @return Returns the looked up value.
     */
    template<>
    std::string k_stat_entry::value(const std::string& attrib) const;

    /**
     * Wrapper around the kstat_ctl structure. It represents our
     * link to kernel stats, and controls the lifetime of any kstat
     * structures associated. (They go away when it is closed)
     */
    struct k_stat
    {
        /**
         * Default constructor.
         * This constructor will handle calling kstat_open.
         */
        k_stat();

        /**
         * Function for looking up a module.
         * @param module The module name.
         * @return Returns the vector containing all entries.
         */
        std::vector<k_stat_entry> operator[](std::string const& module);

        /**
         * Function for looking up a module, and an entry name.
         * @param entry A pair containing module name an entry name.
         * @return Returns the vector containing all entries.
         */
        std::vector<k_stat_entry> operator[](std::pair<std::string, std::string> const& entry);

        /**
         * Function for looking up a module, and an instance id.
         * @param entry A pair containing module name an instance id.
         * @return Returns the vector containing all entries.
         */
        std::vector<k_stat_entry> operator[](std::pair<std::string, int> const& entry);

     private:
        std::vector<k_stat_entry> lookup(std::string const& module, int instance, std::string const& name);
        scoped_kstat ctrl;
    };

}}}  // namespace facter::util::solaris
