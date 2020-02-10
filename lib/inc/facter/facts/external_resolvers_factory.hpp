#ifndef EXTERNAL_RESOLVERS_FACTORY_H
#define EXTERNAL_RESOLVERS_FACTORY_H

#include "../export.h"
#include "external/resolver.hpp"
#include <memory>

namespace facter { namespace facts {
    struct LIBFACTER_NO_EXPORT external_resolvers_factory {
        std::shared_ptr<external::resolver> get_resolver(const std::string&);

        bool text_resolver_can_resolve(std::string const &path);
        bool json_resolver_can_resolve(std::string const &path);
        bool yaml_resolver_can_resolve(std::string const &path);

        bool execution_resolver_can_resolve(std::string const &path);
        bool powershell_resolver_can_resolve(std::string const &path);

        std::shared_ptr<external::resolver> get_common_resolver(const std::string& path);
    };

}}  // namespace facter::facts
#endif  // EXTERNAL_RESOLVERS_FACTORY_H
