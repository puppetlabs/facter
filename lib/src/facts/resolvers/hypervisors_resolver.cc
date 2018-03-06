#include <internal/facts/resolvers/hypervisors_resolver.hpp>
#include <facter/facts/collection.hpp>
#ifdef USE_WHEREAMI
#include <whereami/whereami.hpp>
#endif

using namespace std;
using namespace facter::facts;

namespace facter { namespace facts { namespace resolvers {

    using value_ptr = std::unique_ptr<value>;

    /**
     * Raw pointers must be extracted here because old versions of boost don't allow visitors to return move-only types.
     */
    struct metadata_value_visitor : public boost::static_visitor<value*>
    {
        value* operator()(int value) const
        {
            return make_value<integer_value>(value).release();
        }

        value* operator()(const std::string& value) const
        {
            return make_value<string_value>(value).release();
        }

        value* operator()(bool value) const
        {
            return make_value<boolean_value>(value).release();
        }
    };

    void hypervisors_resolver_base::resolve(collection& facts)
    {
        auto data = collect_data(facts);
        auto hypervisors = make_value<map_value>();

        for (auto const& hypervisor_pair : data) {
            auto hypervisor_metadata = make_value<map_value>();

            for (auto const& metadata_pair : hypervisor_pair.second) {
                value* the_value = boost::apply_visitor(metadata_value_visitor(), metadata_pair.second);
                hypervisor_metadata->add(
                    metadata_pair.first,
                    unique_ptr<value>(the_value));
            }

            hypervisors->add(hypervisor_pair.first, move(hypervisor_metadata));
        }

        if (!hypervisors->empty()) {
            facts.add(fact::hypervisors, move(hypervisors));
        }
    }

#ifdef USE_WHEREAMI
    hypervisor_data hypervisors_resolver::collect_data(collection& facts)
    {
        hypervisor_data data;
        auto results = whereami::hypervisors();

        for (auto const& res : results) {
            data.insert({res.name(), res.metadata()});
        }

        return data;
    }
#endif

    bool hypervisors_resolver_base::is_blockable() const {
        return true;
    }

}}}  // namespace facter::facts::resolvers
