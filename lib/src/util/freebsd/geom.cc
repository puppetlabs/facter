#include <internal/util/freebsd/geom.hpp>
#include <leatherman/locale/locale.hpp>
#include <leatherman/logging/logging.hpp>

using leatherman::locale::_;

using namespace std;

namespace facter { namespace util { namespace freebsd {

    geom_exception::geom_exception(std::string const& message) :
        runtime_error(message)
    {
    }



    geom_config::geom_config(string name, string value)
    {
        _name = name;
        _value = value;
    }

    string
    geom_config::name()
    {
        return _name;
    }

    string
    geom_config::value()
    {
        return _value;
    }



    geom_object_with_config::geom_object_with_config(struct gconf *conf)
    {
        struct gconfig *config;
        LIST_FOREACH(config, conf, lg_config) {
            if (!config->lg_val) {
                LOG_DEBUG(_("Skipping config {1} because it has a null value", config->lg_name));
                continue;
            }
            _configs.push_back(geom_config(config->lg_name, config->lg_val));
        }
    }

    string
    geom_object_with_config::config(string name) {
        for (auto config : _configs) {
            if (config.name() == name)
                return config.value();
        }
        return "";
    }



    geom_provider::geom_provider(struct gprovider* provider) :
        geom_object_with_config(&provider->lg_config)
    {
        _name         = provider->lg_name;
        _mode         = provider->lg_mode;
        _mediasize    = provider->lg_mediasize;
        _sectorsize   = provider->lg_sectorsize;
        _stripeoffset = provider->lg_stripeoffset;
        _stripesize   = provider->lg_stripesize;
    }

    string
    geom_provider::name()
    {
        return _name;
    }

    off_t
    geom_provider::mediasize()
    {
        return _mediasize;
    }



    geom_geom::geom_geom(struct ggeom *geom) :
        geom_object_with_config(&geom->lg_config)
    {
        _name = geom->lg_name;
        struct gprovider *provider;
        LIST_FOREACH(provider, &geom->lg_provider, lg_provider) {
            providers.push_back(geom_provider(provider));
        }
    }

    string
    geom_geom::name()
    {
        return _name;
    }



    geom_class::geom_class(string type)
    {
        if (geom_gettree(&_mesh) < 0) {
            throw geom_exception(_("Unable to get GEOM tree"));
        }

        LIST_FOREACH(_class, &(_mesh.lg_class), lg_class) {
            if (type == string(_class->lg_name))
                break;
        }

        if (!_class) {
            throw geom_exception(_("The GEOM class \"{1}\" was not found", type));
        }

        struct ggeom *geom;
        LIST_FOREACH(geom, &(_class->lg_geom), lg_geom) {
            geoms.push_back(geom_geom(geom));
        }
    }

    geom_class::~geom_class()
    {
        geom_deletetree(&_mesh);
    }

}}}  // namespace facter::util::freebsd
