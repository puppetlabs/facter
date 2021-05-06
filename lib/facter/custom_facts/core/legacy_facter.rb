# frozen_string_literal: true

# Facter - Host Fact Detection and Reporting
#
# Copyright 2011 Puppet Labs Inc
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

require 'pathname'

require_relative '../../../facter/custom_facts/core/file_loader'

# Functions as a hash of 'facts' about your system system, such as MAC
# address, IP address, architecture, etc.
#
# @example Retrieve a fact
#     puts Facter['operatingsystem'].value
#
# @example Retrieve all facts
#   Facter.to_hash
#    => { "kernel"=>"Linux", "uptime_days"=>0, "ipaddress"=>"10.0.0.1" }
#
# @api public
module LegacyFacter
  # Most core functionality of custom_facts is implemented in `Facter::Util`.
  # @api public

  include Comparable
  include Enumerable

  extend LegacyFacter::Core::Logging

  # module methods

  # Accessor for the collection object which holds all the facts
  # @return [LegacyFacter::Util::Collection] the collection of facts
  #
  # @api private
  def self.collection
    unless defined?(@collection) && @collection
      @collection = LegacyFacter::Util::Collection.new(
        LegacyFacter::Util::Loader.new,
        LegacyFacter::Util::Config.ext_fact_loader
      )
    end
    @collection
  end

  # Returns whether the JSON "feature" is available.
  #
  # @api private
  def self.json?
    require 'json'
    true
  rescue LoadError
    false
  end

  # Returns a fact object by name.  If you use this, you still have to
  # call {Facter::Util::Fact#value `value`} on it to retrieve the actual
  # value.
  #
  # @param name [String] the name of the fact
  #
  # @return [Facter::Util::Fact, nil] The fact object, or nil if no fact
  #   is found.
  #
  # @api public
  def self.[](name)
    collection.fact(name)
  end

  # (see [])
  def self.fact(name)
    collection.fact(name)
  end

  # Flushes cached values for all facts. This does not cause code to be
  # reloaded; it only clears the cached results.
  #
  # @return [void]
  #
  # @api public
  def self.flush
    collection.flush
  end

  # Lists all fact names
  #
  # @return [Array<String>] array of fact names
  #
  # @api public
  def self.list
    collection.list
  end

  # Gets the value for a fact. Returns `nil` if no such fact exists.
  #
  # @param name [String] the fact name
  # @return [Object, nil] the value of the fact, or nil if no fact is
  #   found
  #
  # @api public
  def self.value(name)
    collection.value(name)
  end

  # Gets a hash mapping fact names to their values
  #
  # @return [Hash{String => Object}] the hash of fact names and values
  #
  # @api public
  def self.to_hash
    collection.load_all
    collection.to_hash
  end

  # Define a new fact or extend an existing fact.
  #
  # @param name [Symbol] The name of the fact to define
  # @param options [Hash] A hash of options to set on the fact
  #
  # @return [Facter::Util::Fact] The fact that was defined
  #
  # @api public
  # @see {Facter::Util::Collection#define_fact}
  def self.define_fact(name, options = {}, &block)
    collection.define_fact(name, options, &block)
  end

  # Adds a {Facter::Util::Resolution resolution} mechanism for a named
  # fact. This does not distinguish between adding a new fact and adding
  # a new way to resolve a fact.
  #
  # @overload add(name, options = {}, { || ... })
  # @param name [String] the fact name
  # @param options [Hash] optional parameters for the fact - attributes
  #   of {Facter::Util::Fact} and {Facter::Util::Resolution} can be
  #   supplied here
  # @option options [Integer] :timeout set the
  #   {Facter::Util::Resolution#timeout timeout} for this resolution
  # @param block [Proc] a block defining a fact resolution
  #
  # @return [Facter::Util::Fact] the fact object, which includes any previously
  #   defined resolutions
  #
  # @api public
  def self.add(name, options = {}, &block)
    collection.add(name, options, &block)
  end

  # Iterates over fact names and values
  #
  # @yieldparam [String] name the fact name
  # @yieldparam [String] value the current value of the fact
  #
  # @return [void]
  #
  # @api public
  def self.each
    # Make sure all facts are loaded.
    collection.load_all

    collection.each do |*args|
      yield(*args)
    end
  end

  # Clears all cached values and removes all facts from memory.
  #
  # @return [void]
  #
  # @api public
  def self.clear
    LegacyFacter.flush
    LegacyFacter.reset
  end

  # Removes all facts from memory. Use this when the fact code has
  # changed on disk and needs to be reloaded.
  #
  # @return [void]
  #
  # @api public
  def self.reset
    @collection = nil
  end

  # Loads all facts.
  #
  # @return [void]
  #
  # @api public
  def self.loadfacts
    collection.load_all
  end
end
