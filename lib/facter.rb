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

require 'facter/version'

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
module Facter
  # Most core functionality of facter is implemented in `Facter::Util`.
  # @api public
  module Util; end

  require 'facter/util/fact'
  require 'facter/util/collection'
  require 'facter/util/monkey_patches'

  include Comparable
  include Enumerable

  # @api private
  GREEN = "[0;32m"
  # @api private
  RESET = "[0m"
  # @api private
  @@debug = 0
  # @api private
  @@timing = 0
  # @api private
  @@messages = {}
  # @api private
  @@debug_messages = {}

  # module methods

  # Accessor for the collection object which holds all the facts
  # @return [Facter::Util::Collection] the collection of facts
  #
  # @api private
  def self.collection
    unless defined?(@collection) and @collection
      @collection = Facter::Util::Collection.new(
        Facter::Util::Loader.new,
        Facter::Util::Config.ext_fact_loader)
    end
    @collection
  end

  # Prints a debug message if debugging is turned on
  #
  # @param string [String] the debug message
  # @return [void]
  def self.debug(string)
    if string.nil?
      return
    end
    if self.debugging?
      puts GREEN + string + RESET
    end
  end

  # Prints a debug message only once.
  #
  # @note Uniqueness is based on the string, not the specific location
  #   of the method call.
  #
  # @param msg [String] the debug message
  # @return [void]
  def self.debugonce(msg)
    if msg and not msg.empty? and @@debug_messages[msg].nil?
      @@debug_messages[msg] = true
      debug(msg)
    end
  end

  # Returns whether debugging output is turned on
  def self.debugging?
    @@debug != 0
  end

  # Prints a timing
  #
  # @param string [String] the time to print
  # @return [void]
  #
  # @api private
  def self.show_time(string)
    puts "#{GREEN}#{string}#{RESET}" if string and Facter.timing?
  end

  # Returns whether timing output is turned on
  #
  # @api private
  def self.timing?
    @@timing != 0
  end

  # Returns whether the JSON "feature" is available.
  #
  # @api private
  def self.json?
    begin
      require 'json'
      true
    rescue LoadError
      false
    end
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

  class << self
    # Allow users to call fact names directly on the Facter class,
    # either retrieving the value or comparing it to an existing value.
    #
    # @api private
    def method_missing(name, *args)
      question = false
      if name.to_s =~ /\?$/
        question = true
        name = name.to_s.sub(/\?$/,'')
      end

      if fact = collection.fact(name)
        if question
          value = fact.value.downcase
          args.each do |arg|
            if arg.to_s.downcase == value
              return true
            end
          end

          # If we got this far, there was no match.
          return false
        else
          return fact.value
        end
      else
        # Else, fail like a normal missing method.
        raise NoMethodError, "Could not find fact '%s'" % name
      end
    end
  end

  # Clears all cached values and removes all facts from memory.
  #
  # @return [void]
  #
  # @api public
  def self.clear
    Facter.flush
    Facter.reset
  end

  # Clears the seen state of warning messages. See {warnonce}.
  #
  # @return [void]
  #
  # @api private
  def self.clear_messages
    @@messages.clear
  end

  # Sets debugging on or off.
  #
  # @return [void]
  #
  # @api private
  def self.debugging(bit)
    if bit
      case bit
      when TrueClass; @@debug = 1
      when FalseClass; @@debug = 0
      when Fixnum
        if bit > 0
          @@debug = 1
        else
          @@debug = 0
        end
      when String;
        if bit.downcase == 'off'
          @@debug = 0
        else
          @@debug = 1
        end
      else
        @@debug = 0
      end
    else
      @@debug = 0
    end
  end

  # Sets whether timing messages are displayed.
  #
  # @return [void]
  #
  # @api private
  def self.timing(bit)
    if bit
      case bit
      when TrueClass; @@timing = 1
      when Fixnum
        if bit > 0
          @@timing = 1
        else
          @@timing = 0
        end
      end
    else
      @@timing = 0
    end
  end

  # Prints a warning message. The message is only printed if debugging
  # is enabled.
  #
  # @param msg [String] the warning message to be printed
  #
  # @return [void]
  def self.warn(msg)
    if Facter.debugging? and msg and not msg.empty?
      msg = [msg] unless msg.respond_to? :each
      msg.each { |line| Kernel.warn line }
    end
  end

  # Prints a warning message only once per process. Each unique string
  # is printed once.
  #
  # @note Unlike {warn} the message will be printed even if debugging is
  #   not turned on. This behavior is likely to change and should not be
  #   relied on.
  #
  # @param msg [String] the warning message to be printed
  #
  # @return [void]
  def self.warnonce(msg)
    if msg and not msg.empty? and @@messages[msg].nil?
      @@messages[msg] = true
      Kernel.warn(msg)
    end
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

  @search_path = []

  # Registers directories to be searched for facts. Relative paths will
  # be interpreted in the current working directory.
  #
  # @param dirs [String] directories to search
  #
  # @return [void]
  #
  # @api public
  def self.search(*dirs)
    @search_path += dirs
  end

  # Returns the registered search directories.
  #
  # @return [Array<String>] An array of the directories searched
  #
  # @api public
  def self.search_path
    @search_path.dup
  end
end
