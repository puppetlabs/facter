#include <internal/facts/external/yaml_resolver.hpp>
#include <facter/facts/collection.hpp>
#include <facter/facts/array_value.hpp>
#include <facter/facts/map_value.hpp>
#include <facter/facts/scalar_value.hpp>
#include <leatherman/logging/logging.hpp>
#include <leatherman/locale/locale.hpp>
#include <boost/algorithm/string.hpp>
#include <boost/nowide/fstream.hpp>
#include <yaml-cpp/yaml.h>
#include <yaml-cpp/eventhandler.h>

// Mark string for translation (alias for leatherman::locale::format)
using leatherman::locale::_;

using namespace std;
using namespace YAML;

namespace facter { namespace facts { namespace external {

    static void add_value(
        string const& name,
        Node const& node,
        collection& facts,
        array_value* array_parent = nullptr,
        map_value* map_parent = nullptr)
    {
        unique_ptr<value> val;
        // For scalars, code the value into a specific value type
        if (node.IsScalar()) {
            bool bool_val;
            int64_t int_val;
            double double_val;
            // If the node tag is "!", it was a quoted scalar and should be treated as a string
            if (node.Tag() != "!") {
                if (convert<bool>::decode(node, bool_val)) {
                    val = make_value<boolean_value>(bool_val);
                } else if (convert<int64_t>::decode(node, int_val)) {
                    val = make_value<integer_value>(int_val);
                } else if (convert<double>::decode(node, double_val)) {
                    val = make_value<double_value>(double_val);
                }
            }
            if (!val) {
                val = make_value<string_value>(node.as<string>());
            }
        } else if (node.IsSequence()) {
            // For arrays, convert to a array value
            auto array = make_value<array_value>();
            for (auto const& child : node) {
                add_value({}, child, facts, array.get());
            }
            val = move(array);
        } else if (node.IsMap()) {
            // For maps, convert to a map value
            auto map = make_value<map_value>();
            for (auto const& child : node) {
                add_value(child.first.as<string>(), child.second, facts, nullptr, map.get());
            }
            val = move(map);
        } else if (!node.IsNull()) {
            // Ignore nodes we don't understand
            return;
        }

        // Put the value in the array, map, or directly as a top-level fact
        if (array_parent) {
            array_parent->add(move(val));
        } else if (map_parent) {
            map_parent->add(string(name), move(val));
        } else {
            facts.add_external(boost::to_lower_copy(name), move(val));
        }
    }

    bool yaml_resolver::can_resolve(string const& path) const
    {
        return boost::iends_with(path, ".yaml");
    }

    void yaml_resolver::resolve(string const& path, collection& facts) const
    {
        LOG_DEBUG("resolving facts from YAML file \"{1}\".", path);

        boost::nowide::ifstream stream(path.c_str());
        if (!stream) {
            throw external_fact_exception(_("file could not be opened."));
        }

        try {
            Node node = YAML::Load(stream);
            for (auto const& kvp : node) {
                add_value(kvp.first.as<string>(), kvp.second, facts);
            }
        } catch (Exception& ex) {
            throw external_fact_exception(ex.msg);
        }

        LOG_DEBUG("completed resolving facts from YAML file \"{1}\".", path);
    }

}}}  // namespace facter::facts::external
