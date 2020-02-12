/**
 * @file
 * Declares the SSH fact resolver.
 */
#pragma once

#include "resolvers/ssh_resolver.hpp"

namespace facter { namespace facts {

/**
 * Responsible for resolving ssh facts.
 */
struct ssh_resolver : resolvers::ssh_resolver
{
 protected:
    /**
     * Retrieves the fact's key file
     * @param filename The searched key file name.
     * @return Returns the key file's path
     */
    virtual boost::filesystem::path retrieve_key_file(std::string const& filename) override;
};

}}  // namespace facter::facts
