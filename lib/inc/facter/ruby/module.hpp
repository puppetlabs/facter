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
         * @param ruby The Ruby API to use.
         * @param facts The collection of facts to populate.
         */
        module(api const& ruby, facter::facts::collection& facts);

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
        VALUE find(VALUE name, bool create = false);

        /**
         * Gets the value of the given fact name.
         * @param name The name of the fact to get the value of.
         * @return Returns the fact's value or nil if the fact isn't found.
         */
        VALUE value(VALUE name);

        /**
         * Resolves all facts in the Facter module.
         */
        void resolve();

        /**
         * Clears the facts in the module.
         */
        void clear();

        /**
         * Normalizes the given fact name.
         * @param name The fact name to normalize.
         * @return Returns the normalized fact name.
         */
        VALUE normalize(VALUE name) const;

     private:
        static VALUE add_thunk(int argc, VALUE* argv, VALUE self);
        static VALUE define_fact_thunk(int argc, VALUE* argv, VALUE self);
        static VALUE value_thunk(VALUE self, VALUE name);
        static VALUE fact_thunk(VALUE self, VALUE name);
        static VALUE debug_thunk(VALUE self, VALUE message);
        static VALUE debug_once_thunk(VALUE self, VALUE message);
        static VALUE warn_thunk(VALUE self, VALUE message);
        static VALUE warn_once_thunk(VALUE self, VALUE message);
        static VALUE log_exception_thunk(int argc, VALUE* argv, VALUE self);
        static VALUE which_thunk(VALUE self, VALUE binary);
        static VALUE exec_thunk(VALUE self, VALUE command);
        static VALUE execute_thunk(int argc, VALUE* argv, VALUE self);
        VALUE execute_command(std::string const& command, VALUE failure_default, bool raise);

        facter::facts::collection& _collection;
        std::map<std::string, fact> _facts;
        std::set<std::string> _debug_messages;
        std::set<std::string> _warning_messages;
        VALUE _old_facter;
    };

}}  // namespace facter::ruby

#endif  // FACTER_RUBY_MODULE_HPP_
