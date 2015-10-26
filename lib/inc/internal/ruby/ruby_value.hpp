/**
 * @file
 * Declares the Ruby fact value.
 */
#pragma once

#include <leatherman/ruby/api.hpp>
#include "fact.hpp"
#include <facter/facts/value.hpp>

#include <unordered_map>

namespace facter { namespace ruby {

    /**
     * Represents a value for a Ruby fact.
     */
    struct ruby_value : facter::facts::value
    {
        /**
         * Constructs a ruby_value.
         * @param value The Ruby value.
         */
        ruby_value(leatherman::ruby::VALUE value);

        /**
         * Destructs a ruby_value.
         */
        ~ruby_value();

        /**
         * Prevents the ruby_value from being copied.
         */
        ruby_value(ruby_value const&) = delete;

        /**
         * Prevents the ruby_value from being copied.
         * @returns Returns this ruby_value.
         */
        ruby_value& operator=(ruby_value const&) = delete;

        /**
         * Moves the given ruby_value into this ruby_value.
         * @param other The ruby_value to move into this ruby_value.
         */
        ruby_value(ruby_value&& other);

        /**
         * Moves the given ruby_value into this ruby_value.
         * @param other The ruby_value to move into this ruby_value.
         * @return Returns this ruby_value.
         */
        ruby_value& operator=(ruby_value&& other);

        /**
         * Converts the value to a JSON value.
         * @param allocator The allocator to use for creating the JSON value.
         * @param value The returned JSON value.
         */
        virtual void to_json(facts::json_allocator& allocator, facts::json_value& value) const override;

        /**
          * Writes the value to the given stream.
          * @param os The stream to write to.
          * @param quoted True if string values should be quoted or false if not.
          * @param level The current indentation level.
          * @returns Returns the stream being written to.
          */
        virtual std::ostream& write(std::ostream& os, bool quoted = true, unsigned int level = 1) const override;

        /**
          * Writes the value to the given YAML emitter.
          * @param emitter The YAML emitter to write to.
          * @returns Returns the given YAML emitter.
          */
        virtual YAML::Emitter& write(YAML::Emitter& emitter) const override;

        /**
         * Gets the Ruby value.
         * @return Returns the Ruby value.
         */
        leatherman::ruby::VALUE value() const;

        /**
         * Exposes an owned ruby VALUE as a facter ruby_value
         * @param child the owned child object to wrap
         * @param key the query string for the child
         * @return pointer to the ruby_value wrapper for the child object
         */
        ruby_value const* wrap_child(leatherman::ruby::VALUE child, std::string key) const;

        /**
         * Get a cached ruby_value wrapper for a child VALUE
         * @param key the query string for the child
         * @return pointer to the ruby_value wrapper, or nullptr if none exists
         */
        ruby_value const* child(const std::string& key) const;

     private:
        static void to_json(leatherman::ruby::api const& ruby, leatherman::ruby::VALUE value, facts::json_allocator& allocator, facts::json_value& json);
        static void write(leatherman::ruby::api const& ruby, leatherman::ruby::VALUE value, std::ostream& os, bool quoted, unsigned int level);
        static void write(leatherman::ruby::api const& ruby, leatherman::ruby::VALUE value, YAML::Emitter& emitter);

        leatherman::ruby::VALUE _value;

        // This is mutable because of constness that's passed down
        // from the collection object during dot-syntax fact
        // querying. That query is const over the collection, which
        // means the collection's actions on values also need to be
        // const. Unfortunately, we need a place to stash the owning
        // pointer to the new value that we extract from a ruby object
        // during lookup. The logical place for that ownership is the
        // parent ruby object (right here). So we get this cool
        // mutable field that owns the C++ wrappers for looked-up ruby
        // values.
        mutable std::unordered_map<std::string, std::unique_ptr<ruby_value>> _children;
    };

}}  // namespace facter::ruby
