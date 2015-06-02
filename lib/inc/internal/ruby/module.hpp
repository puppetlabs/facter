/**
 * @file
 * Declares the Ruby Facter module.
 */
#pragma once

#include "api.hpp"
#include "fact.hpp"
#include <map>
#include <set>
#include <string>

namespace facter { namespace facts {

    struct collection;

}}  // namespace facter::facts

namespace leatherman { namespace logging {

    enum class log_level;

}}  // namespace leatherman::logging

namespace facter { namespace ruby {

    /**
     * Represents the Ruby Facter module.
     */
    struct module
    {
        /**
         * Constructs the Ruby Facter module.
         * @param facts The collection of facts to populate.
         * @param paths The search paths for loading custom facts.
         */
        module(facter::facts::collection& facts, std::vector<std::string> const& paths = {});

        /**
         * Destructs the Facter module.
         */
        ~module();

        /**
         * Loads all custom facts.
         */
        void load_facts();

        /**
         * Resolves all custom facts.
         */
        void resolve_facts();

        /**
         * Clears the facts.
         * @param clear_collection True if the underlying collection should be cleared or false if not.
         */
        void clear_facts(bool clear_collection = true);

        /**
         * Gets the value of the given fact name.
         * @param name The name of the fact to get the value of.
         * @return Returns the fact's value or nil if the fact isn't found.
         */
        VALUE fact_value(VALUE name);

        /**
         * Normalizes the given fact name.
         * @param name The fact name to normalize.
         * @return Returns the normalized fact name.
         */
        VALUE normalize(VALUE name) const;

        /**
         * Gets the collection associated with the module.
         * @return Returns the collection associated with the Facter module.
         */
        facter::facts::collection& facts();

        /**
         * Gets the module's self.
         * @return Returns the module's self.
         */
        VALUE self() const;

        /**
         * Gets the current module.
         * @return Returns the current module.
         */
        static module* current();

     private:
         // Methods called from Ruby
        static VALUE ruby_version(VALUE self);
        static VALUE ruby_add(int argc, VALUE* argv, VALUE self);
        static VALUE ruby_define_fact(int argc, VALUE* argv, VALUE self);
        static VALUE ruby_value(VALUE self, VALUE name);
        static VALUE ruby_fact(VALUE self, VALUE name);
        static VALUE ruby_debug(VALUE self, VALUE message);
        static VALUE ruby_debugonce(VALUE self, VALUE message);
        static VALUE ruby_warn(VALUE self, VALUE message);
        static VALUE ruby_warnonce(VALUE self, VALUE message);
        static VALUE ruby_log_exception(int argc, VALUE* argv, VALUE self);
        static VALUE ruby_set_debugging(VALUE self, VALUE value);
        static VALUE ruby_get_debugging(VALUE self);
        static VALUE ruby_set_trace(VALUE self, VALUE value);
        static VALUE ruby_get_trace(VALUE self);
        static VALUE ruby_flush(VALUE self);
        static VALUE ruby_list(VALUE self);
        static VALUE ruby_to_hash(VALUE self);
        static VALUE ruby_each(VALUE self);
        static VALUE ruby_clear(VALUE self);
        static VALUE ruby_reset(VALUE self);
        static VALUE ruby_loadfacts(VALUE self);
        static VALUE ruby_search(int argc, VALUE* argv, VALUE self);
        static VALUE ruby_search_path(VALUE self);
        static VALUE ruby_search_external(VALUE self, VALUE paths);
        static VALUE ruby_search_external_path(VALUE self);
        static VALUE ruby_which(VALUE self, VALUE binary);
        static VALUE ruby_exec(VALUE self, VALUE command);
        static VALUE ruby_execute(int argc, VALUE* argv, VALUE self);
        static VALUE ruby_on_message(VALUE self);

        // Helper functions
        static module* from_self(VALUE self);
        static VALUE execute_command(std::string const& command, VALUE failure_default, bool raise, uint32_t timeout = 0);

        void initialize_search_paths(std::vector<std::string> const& paths);
        VALUE load_fact(VALUE value);
        void load_file(std::string const& path);
        VALUE create_fact(VALUE name);
        static VALUE level_to_symbol(leatherman::logging::log_level level);

        facter::facts::collection& _collection;
        std::map<std::string, VALUE> _facts;
        std::set<std::string> _debug_messages;
        std::set<std::string> _warning_messages;
        std::vector<std::string> _search_paths;
        std::vector<std::string> _additional_search_paths;
        std::vector<std::string> _external_search_paths;
        std::set<std::string> _loaded_files;
        bool _loaded_all;
        VALUE _self;
        VALUE _on_message_block;

        static std::map<VALUE, module*> _instances;
    };

}}  // namespace facter::ruby
