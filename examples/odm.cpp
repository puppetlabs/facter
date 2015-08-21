#include <iostream>

#include "internal/util/aix/odm.hpp"
#include <sys/cfgodm.h>

using namespace facter::util::aix;

int main() {
    auto pd_dv = odm_class<PdDv>::open("PdDv");
    auto cu_dv = odm_class<CuDv>::open("CuDv");
    auto cu_at = odm_class<CuAt>::open("CuAt");
    for(const auto& klass : pd_dv.query("class=processor")) {
        std::string ref = klass.uniquetype;
        for(const auto& proc : cu_dv.query("PdDvLn="+ref)) {
            std::string ref = proc.name;
            for(const auto& attr : cu_at.query("name="+ref)) {
                std::cout << "Got attribute " << attr.attribute << "=" << attr.value << " for processor " << proc.name << std::endl;
            }
        }
    }
}
