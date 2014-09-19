/**
 * @file
 * Declares the dynamic library type.
 */
#pragma once

#include <string>
#include <stdexcept>
#include <initializer_list>

namespace facter { namespace util {

    /**
     * Exception thrown for missing imported symbols.
     */
    struct missing_import_exception : std::runtime_error
    {
        /**
         * Constructs a missing_import_exception.
         * @param message The exception message.
         */
        explicit missing_import_exception(std::string const& message);
    };

    /**
     * Represents a dynamic library.
     */
    struct dynamic_library
    {
        /**
         * Constructs a dynamic_library.
         */
        dynamic_library();

        /**
         * Destructs a dynamic_library.
         */
        ~dynamic_library();

        /**
         * Prevents the dynamic_library from being copied.
         */
        dynamic_library(dynamic_library const&) = delete;
        /**
         * Prevents the dynamic_library from being copied.
         * @returns Returns this dynamic_library.
         */
        dynamic_library& operator=(dynamic_library const&) = delete;
        /**
         * Moves the given dynamic_library into this dynamic_library.
         * @param other The dynamic_library to move into this dynamic_library.
         */
        dynamic_library(dynamic_library&& other);
        /**
         * Moves the given dynamic_library into this dynamic_library.
         * @param other The dynamic_library to move into this dynamic_library.
         * @return Returns this dynamic_library.
         */
        dynamic_library& operator=(dynamic_library&& other);

        /**
         * Finds an already loaded library by file name regex pattern.
         * @param pattern The regex pattern of the library to find.
         * @return Returns the already loaded library if found or an unloaded library if not found.
         */
        static dynamic_library find_by_pattern(std::string const& pattern);
        /**
         * Finds an already loaded library by symbol.
         * @param symbol The symbol to find.
         * @return Returns the already loaded library if found or an unloaded library if not found.
         */
        static dynamic_library find_by_symbol(std::string const& symbol);

        /**
         * Loads the given dynamic library.
         * The current library will be closed before the given library is loaded.
         * @param name The name of the library to load.
         * @return Returns true if the library loaded or false if it did not.
         */
        bool load(std::string const& name);

        /**
         * Determines if the library is loaded.
         * @return Returns true if the library is loaded or false if it is not.
         */
        bool loaded() const;

        /**
         * Determines if the library's load was the first.
         * @return Returns true if the library was loaded for the first time or false if it was previously loaded.
         */
        bool first_load() const;

        /**
         * Gets the name of the library.
         * @return Returns the name of the library.
         */
        std::string const& name() const;

        /**
         * Closes the library.
         */
        void close();

        /**
         * Finds a symbol in the library by name.
         * @param name The name of the symbol to find.
         * @param throw_if_missing if true, throws an exception if the symbol is missing.  If false, returns nullptr if the symbol is missing.
         * @param alias The alias of the symbol to load if the given symbol isn't found.
         * @return Returns the symbol's address or nullptr if not found.
         */
        void* find_symbol(std::string const& name, bool throw_if_missing = false, std::string const& alias = {}) const;

     private:
        void* _handle;
        std::string _name;
        bool _first_load;
    };

}}  // namespace facter::util
