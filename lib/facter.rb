# frozen_string_literal: true

require 'pathname'

ROOT_DIR = Pathname.new(File.expand_path('..', __dir__)) unless defined?(ROOT_DIR)

require "#{ROOT_DIR}/lib/framework/core/file_loader"
require "#{ROOT_DIR}/lib/framework/core/options/options_validator"

module Facter
  class ResolveCustomFactError < StandardError; end

  @options = Options.instance
  Log.add_legacy_logger(STDOUT)
  @logger = Log.new(self)
  @already_searched = {}

  class << self
    def clear_messages
      @logger.debug('clear_messages is not implemented')
    end

    # Alias method for Facter.fact()
    # @param name [string] fact name
    #
    # @return [LegacyFacter::Util::Fact, nil] The fact object, or nil if no fact
    #   is found.
    #
    # @api public
    def [](name)
      fact(name)
    end

    # Add custom facts to fact collection
    # @param name [String] Custom fact name
    # @param options = {} [Hash] optional parameters for the fact - attributes
    #   of {Facter::Util::Fact} and {Facter::Util::Resolution} can be
    #   supplied here
    # @param block [Proc] a block defining a fact resolution
    #
    # @return [LegacyFacter::Util::Fact] the fact object, which includes any previously
    #   defined resolutions
    #
    # @api public
    def add(name, options = {}, &block)
      options[:fact_type] = :custom
      LegacyFacter.add(name, options, &block)
      LegacyFacter.collection.invalidate_custom_facts
    end

    # Clears all cached values and removes all facts from memory.
    #
    # @return [nil]
    #
    # @api public
    def clear
      @already_searched = {}
      LegacyFacter.clear
      LegacyFacter.collection.invalidate_custom_facts
      LegacyFacter.collection.reload_custom_facts
    end

    def core_value(user_query)
      user_query = user_query.to_s
      resolved_facts = Facter::FactManager.instance.resolve_core([user_query])
      fact_collection = FactCollection.new.build_fact_collection!(resolved_facts)
      splitted_user_query = Facter::Utils.split_user_query(user_query)
      fact_collection.dig(*splitted_user_query)
    end

    # Prints out a debug message when debug option is set to true
    # @param msg [String] Message to be printed out
    #
    # @return [nil]
    #
    # @api public
    def debug(msg)
      return unless debugging?

      @logger.debug(msg)
      nil
    end

    def on_message(&block)
      Facter::Log.on_message(&block)
    end

    # Check whether debuging is enabled
    #
    # @return [bool]
    #
    # @api public
    def debugging?
      Options[:debug]
    end

    # Enable or disable debugging
    # @param debug_bool [bool] State which debugging should have
    #
    # @return [type] [description]
    #
    # @api public
    def debugging(debug_bool)
      @options.priority_options[:debug] = debug_bool
      @options.refresh

      debug_bool
    end

    # Returns a fact object by name.  If you use this, you still have to
    # call {Facter::Util::Fact#value `value`} on it to retrieve the actual
    # value.
    #
    # @param name [String] the name of the fact
    #
    # @return [LegacyFacter::Util::Fact, nil] The fact object, or nil if no fact
    #   is found.
    #
    # @api public
    def fact(user_query)
      user_query = user_query.to_s
      resolve_fact(user_query)

      @already_searched[user_query]
    end

    # Reset search paths for custom and external facts
    # If config file is set custom and external facts will be reloaded
    #
    # @return [nil]
    #
    # @api public
    def reset
      LegacyFacter.reset
      LegacyFacter.search(*Options.custom_dir)
      LegacyFacter.search_external(Options.external_dir)
      nil
    end

    # Register directories to be searched for custom facts. The registered directories
    # must be absolute paths or they will be ignored.
    #
    # @param dirs [Array<String>] An array of searched directories
    #
    # @return [void]
    #
    # @api public
    def search(*dirs)
      LegacyFacter.search(*dirs)
    end

    # Registers directories to be searched for external facts.
    #
    # @param dirs [Array<String>] An array of searched directories
    #
    # @return [void]
    #
    # @api public
    def search_external(dirs)
      LegacyFacter.search_external(dirs)
    end

    # Returns the registered search directories.for external facts.
    #
    # @return [Array<String>] An array of searched directories
    #
    # @api public
    def search_external_path
      LegacyFacter.search_external_path
    end

    # Returns the registered search directories for custom facts.
    #
    # @return [Array<String>] An array of the directories searched
    #
    # @api public
    def search_path
      LegacyFacter.search_path
    end

    # Gets a hash mapping fact names to their values
    # The hash contains core facts, legacy facts, custom facts and external facts (all facts that can be resolved).
    #
    # @return [FactCollection] the hash of fact names and values
    #
    # @api public
    def to_hash
      @options.priority_options[:to_hash] = true
      @options.refresh

      log_blocked_facts

      resolved_facts = Facter::FactManager.instance.resolve_facts
      CacheManager.invalidate_all_caches
      FactCollection.new.build_fact_collection!(resolved_facts)
    end

    # Check whether printing stack trace is enabled
    #
    # @return [bool]
    #
    # @api public
    def trace?
      LegacyFacter.trace?
    end

    # Enable or disable trace
    # @param debug_bool [bool] Set trace on debug state
    #
    # @return [type] [description]
    #
    # @api public
    def trace(bool)
      LegacyFacter.trace(bool)
    end

    # Gets the value for a fact. Returns `nil` if no such fact exists.
    #
    # @param name [String] the fact name
    # @return [String] the value of the fact, or nil if no fact is found
    #
    # @api public
    def value(user_query)
      user_query = user_query.to_s
      resolve_fact(user_query)
      @already_searched[user_query]&.value
    end

    # Returns Facter version
    #
    # @return [String] Current version
    #
    # @api public
    def version
      version_file = ::File.join(ROOT_DIR, 'VERSION')
      ::File.read(version_file).strip
    end

    # Gets a hash mapping fact names to their values
    #
    # @return [Array] the hash of fact names and values
    #
    # @api private
    def to_user_output(cli_options, *args)
      @options.priority_options = { is_cli: true }.merge!(cli_options.map { |(k, v)| [k.to_sym, v] }.to_h)
      @options.refresh(args)
      @logger.info("executed with command line: #{ARGV.drop(1).join(' ')}")
      log_blocked_facts

      resolved_facts = Facter::FactManager.instance.resolve_facts(args)
      CacheManager.invalidate_all_caches
      fact_formatter = Facter::FormatterFactory.build(@options)

      status = error_check(args, resolved_facts)

      [fact_formatter.format(resolved_facts), status || 0]
    end

    private

    def add_fact_to_searched_facts(user_query, value)
      @already_searched[user_query] ||= ResolvedFact.new(user_query, value)
      @already_searched[user_query].value = value
    end

    # Returns a ResolvedFact and saves the result in @already_searched array that is used as a global collection.
    # @param user_query [String] Fact that needs resolution
    #
    # @return [ResolvedFact]
    def resolve_fact(user_query)
      @options.refresh([user_query])
      user_query = user_query.to_s
      resolved_facts = Facter::FactManager.instance.resolve_facts([user_query])
      CacheManager.invalidate_all_caches
      fact_collection = FactCollection.new.build_fact_collection!(resolved_facts)
      splitted_user_query = Facter::Utils.split_user_query(user_query)

      begin
        value = fact_collection.value(*splitted_user_query)
        add_fact_to_searched_facts(user_query, value)
      rescue KeyError
        nil
      end
    end

    # Returns exit status when user query contains facts that do
    #   not exist
    #
    # @param dirs [Array] Arguments sent to CLI
    # @param dirs [Array] List of resolved facts
    #
    # @return [Integer, nil] Will return status 1 if user query contains
    #  facts that are not found or resolved, otherwise it will return nil
    #
    # @api private
    def error_check(args, resolved_facts)
      if Options.instance[:strict]
        missing_names = args - resolved_facts.map(&:user_query).uniq
        if missing_names.count.positive?
          status = 1
          log_errors(missing_names)
        else
          status = nil
        end
      end

      status
    end

    # Prints out blocked facts before to_hash or to_user_output is called
    #
    # @return [nil]
    #
    # @api private
    def log_blocked_facts
      block_list = BlockList.instance.block_list
      @logger.debug("blocking collection of #{block_list.join("\s")} facts") if block_list.any? && Options[:block]
    end

    # Used for printing errors regarding CLI user input validation
    #
    # @param missing_names [Array] List of facts that were requested
    #  but not found
    #
    # @return [nil]
    #
    # @api private
    def log_errors(missing_names)
      missing_names.each do |missing_name|
        @logger.error("fact \"#{missing_name}\" does not exist.", true)
      end
    end

    # Proxy method that catches not yet implemented method calls
    #
    # @param name [type] [description]
    # @param *args [type] [description]
    # @param &block [type] [description]
    #
    # @return [type] [description]
    #
    # @api private
    def method_missing(name, *args, &block)
      @logger.error(
        "--#{name}-- not implemented but required \n" \
        'with params: ' \
        "#{args.inspect} \n" \
        'with block: ' \
        "#{block.inspect}  \n" \
        "called by:  \n" \
        "#{caller} \n"
      )
      nil
    end
  end
end
