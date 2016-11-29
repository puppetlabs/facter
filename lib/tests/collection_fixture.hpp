#pragma once

#include <facter/facts/collection.hpp>
#include <vector>
#include <string>

namespace facter { namespace testing {

    class collection_fixture : public facter::facts::collection
    {
    public:
        collection_fixture(std::set<std::string> const& blocklist = std::set<std::string>(),
                std::unordered_map<std::string, int64_t> const& ttls = std::unordered_map<std::string, int64_t>{});

    protected:
        virtual std::vector<std::string> get_external_fact_directories() const override;
    };

}}  // namespace facter::testing
