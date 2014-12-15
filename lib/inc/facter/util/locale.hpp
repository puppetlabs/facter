/**
* @file
* Declares utility functions for setting the locale.
*/
#pragma once



namespace facter { namespace util {

    /**
     * Sets the locale to the specified locale id, and imbues it in boost::filesystem
     * @args id The locale ID, defaults to the system default
     */
    void set_locale(std::string const& id = "");

}}
