#include <facter/facts/external/yaml_resolver.hpp>
#include <facter/facts/fact_map.hpp>
#include <facter/facts/array_value.hpp>
#include <facter/facts/map_value.hpp>
#include <facter/facts/scalar_value.hpp>
#include <facter/logging/logging.hpp>
#include <facter/util/string.hpp>
#include <yaml-cpp/yaml.h>
#include <yaml-cpp/eventhandler.h>
#include <fstream>

using namespace std;
using namespace facter::util;
using namespace YAML;

LOG_DECLARE_NAMESPACE("facts.external.yaml");

namespace facter { namespace facts { namespace external {

    static void add_value(
        string const& name,
        Node const& node,
        fact_map& facts,
        vector<unique_ptr<value>>* array_parent = nullptr,
        map<string, unique_ptr<value>>* map_parent = nullptr)
    {
        unique_ptr<value> val;
        // For scalars, code the value into a specific value type
        if (node.IsScalar()) {
            bool bool_val;
            int64_t int_val;
            double double_val;
            if (convert<bool>::decode(node, bool_val)) {
                val = make_value<boolean_value>(bool_val);
            } else if (convert<int64_t>::decode(node, int_val)) {
                val = make_value<integer_value>(int_val);
            } else if (convert<double>::decode(node, double_val)) {
                val = make_value<double_value>(double_val);
            } else {
                val = make_value<string_value>(node.as<string>());
            }
        } else if (node.IsSequence()) {
            // For sequences, convert to an array value
            vector<unique_ptr<value>> members;
            for (auto const& child : node) {
                add_value({}, child, facts, &members);
            }

            val = make_value<array_value>(move(members));
        } else if (node.IsMap()) {
            // For maps, convert to a map value
            map<string, unique_ptr<value>> members;
            for (auto const& child : node) {
                add_value(child.first.as<string>(), child.second, facts, nullptr, &members);
            }
            val = make_value<map_value>(move(members));
        } else if (!node.IsNull()) {
            // Ignore nodes we don't understand
            return;
        }

        // Put the value in the array, map, or directly as a top-level fact
        if (array_parent) {
            array_parent->emplace_back(move(val));
        } else if (map_parent) {
            map_parent->emplace(name, move(val));
        } else {
            facts.add(string(name), move(val));
        }
    }

    bool yaml_resolver::resolve(std::string const& path, fact_map& facts) const
    {
        string full_path = path;
        if (!ends_with(to_lower(full_path), ".yaml")) {
            return false;
        }

        LOG_DEBUG("resolving facts from YAML file \"%1%\".", path);

        ifstream stream(path);
        if (!stream) {
            throw external_fact_exception("file could not be opened.");
        }

        try {
            Node node = YAML::Load(stream);
            for (auto const& kvp : node) {
                add_value(kvp.first.as<string>(), kvp.second, facts);
            }
        } catch (Exception& ex) {
            throw external_fact_exception(ex.msg);
        }

        LOG_DEBUG("completed resolving facts from YAML file \"%1%\".", path);
        return true;
    }

}}}  // namespace facter::facts::external
