/**
 * @file
 * Declares functions for accessing the Facter configuration file.
 */
#pragma once

#include "../export.h"
#include <hocon/config.hpp>

namespace facter { namespace config {

    class LIBFACTER_EXPORT config {
        public:
            /**
             * Creates a config object from the file at the provided path,
             * which wraps a cpp-hocon config object. This config
             * can be queried for specific settings.
             * @param file_path the full path to the config file
             */
            static config instance(std::string const& file_path);

            /**
             * Reloads all the settings from the configuration file.
             * @param file_path the full path to the config file
             */
            void reload_from_file(std::string const& file_path);

            /**
             * Checks whether the specified setting is present in the config file.
             * @param setting_path dot-separated path to the desired setting
             * @return true if the setting appears in the file, false otherwise
             */
            bool has_setting(std::string const& setting_path);

            /**
             * Returns an item of type T representing the value of the setting at the given path.
             * Throws an exception if the setting value is of the wrong type, or if the setting does not exist.
             * @param setting_path dot-separated path to the desired setting
             * @return the value of the setting
             */
            template<typename T>
            T get_setting(std::string const& setting_path) {
                return boost::get<T>(_config->get_any_ref(setting_path));
            }

            /**
             * Returns a list of items of type T representing the value of the list setting at the given path.
             * Throws an exception if the setting does not exist or if the list is of the wrong type or not homogeneous.
             * @param setting_path dot-separated path to the desired setting
             * @return a list of the values in the setting
             */
            template<typename T>
            std::vector<T> get_list_setting(std::string const& setting_path) {
                return _config->get_homogeneous_unwrapped_list<T>(setting_path);
            }

        private:
            config(hocon::shared_config hocon_conf);

            hocon::shared_config _config;
    };

}}  // namespace facter::config

