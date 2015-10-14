/**
 * @file
 * Declares the Ruby Facter module.
 */
#pragma once

#include <leatherman/ruby/api.hpp>
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
         * @param logging_hooks True if the logging hooks should be defined in the Facter API or false if not.
         */
        module(facter::facts::collection& facts, std::vector<std::string> const& paths = {}, bool logging_hooks = true);

        /**
         * Destructs the Facter module.
         */
        ~module();

        /**
         * Add additional search paths for ruby custom facts
         * @param paths The search paths for loading custom facts
         */
        void search(std::vector<std::string> const& paths);

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
        leatherman::ruby::VALUE fact_value(leatherman::ruby::VALUE name);

        /**
         * Converts the given value to a corresponding Ruby object.
         * @param val The value to convert.
         * @return Returns a Ruby object for the value.
         */
        leatherman::ruby::VALUE to_ruby(facter::facts::value const* val) const;

        /**
         * Normalizes the given fact name.
         * @param name The fact name to normalize.
         * @return Returns the normalized fact name.
         */
        leatherman::ruby::VALUE normalize(leatherman::ruby::VALUE name) const;

        /**
         * Gets the collection associated with the module.
         * @return Returns the collection associated with the Facter module.
         */
        facter::facts::collection& facts();

        /**
         * Gets the module's self.
         * @return Returns the module's self.
         */
        leatherman::ruby::VALUE self() const;

        /**
         * Gets the current module.
         * @return Returns the current module.
         */
        static module* current();

     private:
         // Methods called from Ruby
        static leatherman::ruby::VALUE ruby_version(leatherman::ruby::VALUE self);
        static leatherman::ruby::VALUE ruby_add(int argc, leatherman::ruby::VALUE* argv, leatherman::ruby::VALUE self);
        static leatherman::ruby::VALUE ruby_define_fact(int argc, leatherman::ruby::VALUE* argv, leatherman::ruby::VALUE self);
        static leatherman::ruby::VALUE ruby_value(leatherman::ruby::VALUE self, leatherman::ruby::VALUE name);
        static leatherman::ruby::VALUE ruby_fact(leatherman::ruby::VALUE self, leatherman::ruby::VALUE name);
        static leatherman::ruby::VALUE ruby_debug(leatherman::ruby::VALUE self, leatherman::ruby::VALUE message);
        static leatherman::ruby::VALUE ruby_debugonce(leatherman::ruby::VALUE self, leatherman::ruby::VALUE message);
        static leatherman::ruby::VALUE ruby_warn(leatherman::ruby::VALUE self, leatherman::ruby::VALUE message);
        static leatherman::ruby::VALUE ruby_warnonce(leatherman::ruby::VALUE self, leatherman::ruby::VALUE message);
        static leatherman::ruby::VALUE ruby_log_exception(int argc, leatherman::ruby::VALUE* argv, leatherman::ruby::VALUE self);
        static leatherman::ruby::VALUE ruby_set_debugging(leatherman::ruby::VALUE self, leatherman::ruby::VALUE value);
        static leatherman::ruby::VALUE ruby_get_debugging(leatherman::ruby::VALUE self);
        static leatherman::ruby::VALUE ruby_set_trace(leatherman::ruby::VALUE self, leatherman::ruby::VALUE value);
        static leatherman::ruby::VALUE ruby_get_trace(leatherman::ruby::VALUE self);
        static leatherman::ruby::VALUE ruby_flush(leatherman::ruby::VALUE self);
        static leatherman::ruby::VALUE ruby_list(leatherman::ruby::VALUE self);
        static leatherman::ruby::VALUE ruby_to_hash(leatherman::ruby::VALUE self);
        static leatherman::ruby::VALUE ruby_each(leatherman::ruby::VALUE self);
        static leatherman::ruby::VALUE ruby_clear(leatherman::ruby::VALUE self);
        static leatherman::ruby::VALUE ruby_reset(leatherman::ruby::VALUE self);
        static leatherman::ruby::VALUE ruby_loadfacts(leatherman::ruby::VALUE self);
        static leatherman::ruby::VALUE ruby_search(int argc, leatherman::ruby::VALUE* argv, leatherman::ruby::VALUE self);
        static leatherman::ruby::VALUE ruby_search_path(leatherman::ruby::VALUE self);
        static leatherman::ruby::VALUE ruby_search_external(leatherman::ruby::VALUE self, leatherman::ruby::VALUE paths);
        static leatherman::ruby::VALUE ruby_search_external_path(leatherman::ruby::VALUE self);
        static leatherman::ruby::VALUE ruby_which(leatherman::ruby::VALUE self, leatherman::ruby::VALUE binary);
        static leatherman::ruby::VALUE ruby_exec(leatherman::ruby::VALUE self, leatherman::ruby::VALUE command);
        static leatherman::ruby::VALUE ruby_execute(int argc, leatherman::ruby::VALUE* argv, leatherman::ruby::VALUE self);
        static leatherman::ruby::VALUE ruby_on_message(leatherman::ruby::VALUE self);

        // Helper functions
        static module* from_self(leatherman::ruby::VALUE self);
        static leatherman::ruby::VALUE execute_command(std::string const& command, leatherman::ruby::VALUE failure_default, bool raise, uint32_t timeout = 0);

        void initialize_search_paths(std::vector<std::string> const& paths);
        leatherman::ruby::VALUE load_fact(leatherman::ruby::VALUE value);
        void load_file(std::string const& path);
        leatherman::ruby::VALUE create_fact(leatherman::ruby::VALUE name);
        static leatherman::ruby::VALUE level_to_symbol(leatherman::logging::log_level level);

        facter::facts::collection& _collection;
        std::map<std::string, leatherman::ruby::VALUE> _facts;
        std::set<std::string> _debug_messages;
        std::set<std::string> _warning_messages;
        std::vector<std::string> _search_paths;
        std::vector<std::string> _additional_search_paths;
        std::vector<std::string> _external_search_paths;
        std::set<std::string> _loaded_files;
        bool _loaded_all;
        leatherman::ruby::VALUE _self;
        leatherman::ruby::VALUE _on_message_block;

        static std::map<leatherman::ruby::VALUE, module*> _instances;
    };

}}  // namespace facter::ruby
