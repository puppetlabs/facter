/**
 * @file
 * Declares the base class for Ruby resolution classes.
 */
#pragma once

#include <leatherman/ruby/api.hpp>
#include "confine.hpp"
#include <vector>
#include <memory>

namespace facter { namespace facts {

    struct value;

}}  // namespace facter::facts

namespace facter { namespace ruby {

    struct module;

    /**
     * The base class for Ruby resolution classes.
     */
    struct resolution
    {
        /**
         * Gets the name of the resolution.
         * @return Returns the name of the resolution or nil if the resolution has no name.
         */
        leatherman::ruby::VALUE name() const;

        /**
         * Sets the name of the resolution.
         * @param name The name of the resolution.
         */
        void name(leatherman::ruby::VALUE name);

        /**
         * Gets the weight of the resolution.
         * The higher the weight value, the more precedence is given to the resolution.
         * @return Returns the weight of the resolution.
         */
        size_t weight() const;

        /**
         * Sets the weight of the resolution.
         * @param weight The weight of the resolution.
         */
        void weight(size_t weight);

        /**
         * Gets the value of the resolution.
         * @return Returns the value of the resolution or nil if the value did not resolve.
         */
        virtual leatherman::ruby::VALUE value();

        /**
         * Sets the value of the resolution.
         * @param v The value of the resolution.
         */
        void value(leatherman::ruby::VALUE v);

        /**
         * Determines if the resolution is suitable.
         * @param facter The Ruby facter module to resolve facts with.
         * @returns Returns true if the resolution is allowed or false if it is not.
         */
        bool suitable(module& facter) const;

        /**
         * Confines the resolution.
         * @param confines The confines for the resolution.
         */
        void confine(leatherman::ruby::VALUE confines);

        /**
         * Calls the on_flush block for the resolution, if there is one.
         */
        void flush() const;

     protected:
        /**
         * Constructs the resolution.
         */
        resolution();

        /**
         * Destructs the resolution.
         */
        virtual ~resolution();

        /**
         * Defines the base methods on the given class.
         * @param klass The Ruby class to define the base methods on.
         */
        static void define(leatherman::ruby::VALUE klass);

        /**
         * Called to mark this object's values during GC.
         */
        void mark() const;

     private:
        // Construction and assignment
        resolution(resolution const&) = delete;
        resolution& operator=(resolution const&) = delete;
        resolution(resolution&& other) = delete;
        resolution& operator=(resolution&& other) = delete;

        // Methods called from Ruby
        static leatherman::ruby::VALUE ruby_confine(int argc, leatherman::ruby::VALUE* argv, leatherman::ruby::VALUE self);
        static leatherman::ruby::VALUE ruby_has_weight(leatherman::ruby::VALUE self, leatherman::ruby::VALUE value);
        static leatherman::ruby::VALUE ruby_name(leatherman::ruby::VALUE self);
        static leatherman::ruby::VALUE ruby_timeout(leatherman::ruby::VALUE self, leatherman::ruby::VALUE timeout);
        static leatherman::ruby::VALUE ruby_on_flush(leatherman::ruby::VALUE self);

        leatherman::ruby::VALUE _name;
        leatherman::ruby::VALUE _value;
        leatherman::ruby::VALUE _flush_block;
        std::vector<ruby::confine> _confines;
        bool _has_weight;
        size_t _weight;
    };

}}  // namespace facter::ruby
