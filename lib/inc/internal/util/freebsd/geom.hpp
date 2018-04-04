/**
 * @file
 * Declares geom.
 */
#pragma once

#include <string>
#include <vector>

#include <libgeom.h>

namespace facter { namespace util { namespace freebsd {

    /**
     * geom exceptions
     */
    struct geom_exception : std::runtime_error
    {
        /**
         * Constructs a geom_exception.
         * @param message the exception message.
         */
        explicit geom_exception(std::string const& message);
    };

    /**
     * GEOM configuration.
     * This is a wrapper for struct gconfig.
     */
    class geom_config {
    private:
        std::string _name;
        std::string _value;
    public:
        /**
         * Constructs a GEOM configuration item.
         * @param name the name of the item.
         * @param value the valure of the item.
         */
        geom_config(std::string name, std::string value);
        /**
         * Returns the name of the item.
	 * @return the name of the item.
         */
        std::string name();
        /**
         * Returns the value of the item.
         * @return the value of the item.
         */
        std::string value();
    };

    /**
     * Base GEOM class capable of storing configuration.
     */
    class geom_object_with_config {
    private:
        std::vector<geom_config> _configs;
    protected:
        /**
         * Loads GEOM configuration.
         * @param conf the first configuration item.
         */
        geom_object_with_config(struct gconf *conf);
    public:
        /**
         * Fetches a configuration value from the object.
         * @param name the name of the configuration to get.
         * @return the value of the configuration.
         */
        std::string config(std::string name);
    };

    /**
     * GEOM providers.
     * This is a wrapper for struct gprovider.
     */
    class geom_provider : public geom_object_with_config {
    private:
        std::string _name;
        std::string _mode;
        off_t _mediasize;
        u_int _sectorsize;
        off_t _stripeoffset;
        off_t _stripesize;
    public:
        /**
         * Loads a GEOM provider.
         * @param provider the provider to load.
         */
        geom_provider(struct gprovider* provider);
        /**
         * Returns the provider name.
         * @return the name of the provider.
         */
        std::string name();
        /**
         * Returns the provider media size.
         * @return the media size in bytes.
         */
        off_t mediasize();
    };

    /**
     * GEOM geoms (sic).
     * This is a wrapper for struct ggeom.
     */
    class geom_geom : public geom_object_with_config {
    private:
        std::string _name;
    public:
        /**
         * Loads a GEOM Geom.
         * @param geom the Geom to load.
         */
        geom_geom(struct ggeom *geom);
        /**
         * Providers attached to this Geom.
         */
        std::vector<geom_provider> providers;
        /**
         * Returns the name of the Geom.
         * @return the name of the Geom.
         */
        std::string name();
    };

    /**
     * GEOM classes.
     * This is a wrapper for struct gclass.
     */
    class geom_class {
    private:
        struct gmesh _mesh;
        struct gclass *_class;
    public:
        /**
         * Loads a GEOM class. Throws a geom_exception on failure.
         * @param type the GEOM class to load.
         */
        geom_class(std::string type);
        ~geom_class();
        /**
         * Geoms attached to this class.
         */
        std::vector<geom_geom> geoms;
    };

}}}  // namespace facter::util::freebsd
