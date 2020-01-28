#pragma once

#include "../resolvers/ssh_resolver.hpp"

namespace facter { namespace facts { namespace windows {

/**
 * Responsible for resolving ssh facts.
 */
struct ssh_resolver : resolvers::ssh_resolver
{
 protected:
    /**
     * Collects the resolver data.
     * @param facts The fact collection that is resolving facts.
     * @return Returns the resolver data.
     */
    virtual data collect_data(collection& facts) override;

 private:
    void populate_key(std::string const& filename, int type, ssh_key& key);
};

}}}  // namespace facter::facts::windows
