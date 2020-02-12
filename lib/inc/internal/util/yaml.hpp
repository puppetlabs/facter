/**
 * @file
 * Declares helper methods for dealing with YAML
 */
#pragma once

#include <string>
#include <vector>

namespace YAML {
    class Node;
}

namespace facter { namespace facts {
    struct collection;
    struct array_value;
    struct map_value;
}}

namespace facter { namespace util { namespace yaml {
    /**
     * Adds a YAML value into a Facter collection.
     */
    void add_value(std::string const& name, YAML::Node const& node,
                   facts::collection& facts, std::vector<std::string>& names,
                   facts::array_value* array_parent = nullptr, facts::map_value* map_parent = nullptr);
}}}
