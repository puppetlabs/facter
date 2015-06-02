/**
 * @file
 * Declares the BSD file system fact resolver.
 */
#pragma once

#include "../resolvers/filesystem_resolver.hpp"

struct statfs;

namespace facter { namespace facts { namespace bsd {

    /**
     * Responsible for resolving BSD file system facts.
     */
    struct filesystem_resolver : resolvers::filesystem_resolver
    {
     protected:
        /**
         * Collects the file system data.
         * @param facts The fact collection that is resolving facts.
         * @return Returns the file system data.
         */
        virtual data collect_data(collection& facts) override;

     private:
        static std::vector<std::string> to_options(struct statfs const& fs);
    };

}}}  // namespace facter::facts::bsd
