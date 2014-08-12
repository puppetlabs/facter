/**
 * @file
 * Declares the Ruby Facter module.
 */
#ifndef FACTER_RUBY_MODULE_HPP_
#define FACTER_RUBY_MODULE_HPP_

#include "api.hpp"
#include "object.hpp"
#include "fact.hpp"
#include <map>
#include <set>
#include <string>

namespace facter { namespace facts {

    struct collection;

}}  // namespace facter::facts

namespace facter { namespace ruby {

    /**
     * Represents the Ruby Facter module.
     */
    struct module : object<module>
    {
        /**
         * Constructs the Ruby Facter module.
         * @param facts The collection of facts to populate.
         */
        module(facter::facts::collection& facts);

        /**
         * Destructs the Facter module.
         */
        ~module();

        /**
         * Finds a fact with the given name.
         * @param name The name of the fact to find.
         * @param create True if a missing fact should be created or false if nil should be returned.
         * @return Returns the Fact's self or nil.
         */
        VALUE find_fact(VALUE name, bool create = false);

        /**
         * Gets the value of the given fact name.
         * @param name The name of the fact to get the value of.
         * @return Returns the fact's value or nil if the fact isn't found.
         */
        VALUE fact_value(VALUE name);

        /**
         * Resolves all facts in the Facter module.
         */
        void resolve_facts();

        /**
         * Clears the facts in the module.
         */
        void clear_facts();

        /**
         * Normalizes the given fact name.
         * @param name The fact name to normalize.
         * @return Returns the normalized fact name.
         */
        VALUE normalize(VALUE name) const;

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
        static VALUE ruby_which(VALUE self, VALUE binary);
        static VALUE ruby_exec(VALUE self, VALUE command);
        static VALUE ruby_execute(int argc, VALUE* argv, VALUE self);

        // Helper functions
        static VALUE execute_command(std::string const& command, VALUE failure_default, bool raise);

        facter::facts::collection& _collection;
        std::map<std::string, VALUE> _facts;
        std::set<std::string> _debug_messages;
        std::set<std::string> _warning_messages;
        VALUE _previous_facter;
    };

}}  // namespace facter::ruby

#endif  // FACTER_RUBY_MODULE_HPP_
