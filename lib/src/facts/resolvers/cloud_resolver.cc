#include <internal/facts/resolvers/cloud_resolver.hpp>
#include <facter/facts/collection.hpp>
#include <facter/facts/fact.hpp>
#include <facter/facts/map_value.hpp>
#include <facter/facts/scalar_value.hpp>
#include <leatherman/logging/logging.hpp>
#include <leatherman/locale/locale.hpp>

// Mark string for translation (alias for leatherman::locale::format)
using leatherman::locale::_;

using namespace std;

namespace facter { namespace facts { namespace resolvers {

    cloud_resolver::cloud_resolver() :
        resolver("cloud", { fact::cloud })
    {
    }

    void cloud_resolver::resolve(collection& facts)
    {
        LOG_DEBUG("resolving cloud fact");
        auto data = collect_data(facts);

        if (!data.provider.empty()) {
            auto cloud = make_value<map_value>();
            cloud->add("provider", make_value<string_value>(data.provider));
            facts.add(fact::cloud, move(cloud));
        }
    }

    cloud_resolver::data cloud_resolver::collect_data(collection& facts)
    {
        data result;

        string cloud_provider = get_azure(facts);
        if (!cloud_provider.empty()) {
            result.provider = cloud_provider;
        }

        return result;
    }

    string cloud_resolver::get_azure(collection& facts)
    {
        string provider;
        auto az_metadata = facts.get<map_value>(fact::az_metadata);

        if (az_metadata && !az_metadata->empty()) {
            provider = "azure";
        }

        return provider;
    }

}}}  // namespace facter::facts::resolvers
