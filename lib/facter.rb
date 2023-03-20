# frozen_string_literal: true

require 'pathname'
require_relative 'util/api_debugger' if ENV['API_DEBUG']

require_relative 'facter/version'
require_relative 'facter/framework/core/file_loader'
require_relative 'facter/framework/core/options/options_validator'

module Facter
  class ResolveCustomFactError < StandardError; end

  Options.init
  Log.output(STDOUT)
  @already_searched = {}

  class << self
    # Method used by puppet-agent to retrieve facts
    # @param args_as_string [string] facter cli arguments
    #
    # @return [Hash<String, Object>]
    #
    # @api private
    def resolve(args_as_string)
      require_relative 'facter/framework/cli/cli_launcher'

      args = args_as_string.split(' ')
      Facter::OptionsValidator.validate(args)
      processed_arguments = CliLauncher.prepare_arguments(args, nil)
      cli = Facter::Cli.new([], processed_arguments)
      cli_options = cli.options.dup

      # config file options
      config_file = cli_options.delete(:config)
      if config_file
        Facter::OptionStore.set(:config, config_file)
        Facter::ConfigFileOptions.init(config_file)
        Facter::Options.store(ConfigFileOptions.get)
      end

      # user provided options
      cli_options[:show_legacy] ||= false
      Facter::Options.store(cli_options)

      Hash[queried_facts(cli.args)]
    end

    # Method used by cli to set puppet paths
    # in order to retrieve puppet custom and external facts
    #
    # @return nil
    #
    # @api private
    def puppet_facts
      require 'puppet'

      # don't allow puppet logger to be injected in Facter
      Options[:allow_external_loggers] = false

      Puppet.initialize_settings
      $LOAD_PATH << Puppet[:libdir] unless $LOAD_PATH.include?(Puppet[:libdir])
      Facter.reset
      Facter.search_external([Puppet[:pluginfactdest]])
      if Puppet.respond_to? :initialize_facts
        Puppet.initialize_facts
      else
        Facter.add(:puppetversion) do
          setcode { Puppet.version.to_s }
        end
      end
    rescue LoadError => e
      logger.error("Could not load puppet gem, got #{e}")
    end

    # Alias method for Facter.fact()
    # @param name [string] fact name
    #
    # @return [Facter::Util::Fact, nil] The fact object, or nil if no fact
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
    # @return [Facter::Util::Fact] the fact object, which includes any previously
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
      Facter.clear_messages
      LegacyFacter.clear
      Options[:custom_dir] = []
      LegacyFacter.collection.invalidate_custom_facts
      LegacyFacter.collection.reload_custom_facts
      SessionCache.invalidate_all_caches
      nil
    end

    # Clears the seen state of debug and warning messages.
    #
    # @return [nil]
    def clear_messages
      Facter::Log.clear_messages
    end

    # Retrieves the value of a core fact. External or custom facts are
    # not returned with this call. Returns `nil` if no such fact exists.
    #
    # @return [FactCollection] A hash with fact names and values
    #
    # @api private
    def core_value(user_query)
      user_query = user_query.to_s
      resolved_facts = Facter::FactManager.instance.resolve_core([user_query])
      fact_collection = FactCollection.new.build_fact_collection!(resolved_facts)
      splitted_user_query = Facter::Utils.split_user_query(user_query)
      fact_collection.dig(*splitted_user_query)
    end

    # Logs debug message when debug option is set to true
    # @param message [Object] Message object to be logged
    #
    # @return [nil]
    #
    # @api public
    def debug(message)
      return unless debugging?

      logger.debug(message.to_s)
      nil
    end

    # Logs the same debug message only once when debug option is set to true
    # @param message [Object] Message object to be logged
    #
    # @return [nil]
    #
    # @api public
    def debugonce(message)
      logger.debugonce(message)
      nil
    end

    # Define a new fact or extend an existing fact.
    #
    # @param name [Symbol] The name of the fact to define
    # @param options [Hash] A hash of options to set on the fact
    #
    # @return [Facter::Util::Fact] The fact that was defined
    #
    # @api public
    def define_fact(name, options = {}, &block)
      options[:fact_type] = :custom
      LegacyFacter.define_fact(name, options, &block)
    end

    # Stores a proc that will be used to output custom messages.
    #   The proc must receive one parameter that will be the message to log.
    # @param block [Proc] a block defining messages handler
    #
    # @return [nil]
    #
    # @api public
    def on_message(&block)
      Facter::Log.on_message(&block)
      nil
    end

    # Check whether debugging is enabled
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
      Facter::Options[:debug] = debug_bool
    end

    # Check whether http debugging is enabled
    #
    # @return [bool]
    #
    # @api public
    def http_debug?
      Options[:http_debug]
    end

    # Enable or disable http debugging
    # @param debug_bool [bool] State which http debugging should have
    #
    # @return [type] [description]
    #
    # @api public
    def http_debug(http_debug_bool)
      Facter::Options[:http_debug] = http_debug_bool
    end

    # Enable sequential resolving of facts
    #
    # @return [bool]
    #
    # @api public
    def enable_sequential
      Facter::Options[:sequential] = true
    end

    # Disable sequential resolving of facts
    #
    # @return [bool]
    #
    # @api public
    def disable_sequential
      Facter::Options[:sequential] = false
    end

    # Check if facts are resolved sequentially or not
    #
    # @return [bool]
    #
    # @api public
    def sequential?
      Facter::Options[:sequential]
    end

    # Iterates over fact names and values
    #
    # @yieldparam [String] name the fact name
    # @yieldparam [String] value the current value of the fact
    #
    # @return [Facter]
    #
    # @api public
    def each
      log_blocked_facts
      resolved_facts = Facter::FactManager.instance.resolve_facts

      resolved_facts.each do |fact|
        yield(fact.name, fact.value)
      end

      self
    end

    # Reset search paths for custom and external facts
    # If config file is set custom and external facts will be reloaded
    #
    # @return [nil]
    #
    # @api public
    def reset
      LegacyFacter.reset
      Options[:custom_dir] = []
      Options[:external_dir] = []
      SessionCache.invalidate_all_caches
      nil
    end

    # Flushes cached values for all facts. This does not cause code to be
    # reloaded; it only clears the cached results.
    #
    # @return [void]
    #
    # @api public
    def flush
      LegacyFacter.flush
      SessionCache.invalidate_all_caches
      nil
    end

    # Loads all facts
    #
    # @return [nil]
    #
    # @api public
    def loadfacts
      LegacyFacter.loadfacts
      nil
    end

    # Enables/Disables external facts.
    # @param enable_external [boolean]
    #
    #  @return nil
    #
    # @api public
    def load_external(enable_external)
      # enable_external param needs negation because behind the scene
      # no_external_facts= method is negating the parameter again.
      Options[:no_external_facts] = !enable_external

      if enable_external
        logger.debug('Facter.load_external(true) called. External facts will be loaded')
      else
        logger.debug('Facter.load_external(false) called. External facts will NOT be loaded')
      end

      nil
    end

    # Register directories to be searched for custom facts. The registered directories
    #   must be absolute paths or they will be ignored.
    # @param dirs [Array<String>] An array of searched directories
    #
    # @return [nil]
    #
    # @api public
    def search(*dirs)
      Options[:custom_dir] += dirs
      nil
    end

    # Registers directories to be searched for external facts.
    # @param dirs [Array<String>] An array of searched directories
    #
    # @return [nil]
    #
    # @api public
    def search_external(dirs)
      Options[:external_dir] += dirs
      nil
    end

    # Returns the registered search directories.for external facts.
    #
    # @return [Array<String>] An array of searched directories
    #
    # @api public
    def search_external_path
      Options.external_dir
    end

    # Returns the registered search directories for custom facts.
    #
    # @return [Array<String>] An array of the directories searched
    #
    # @api public
    def search_path
      Options.custom_dir
    end

    # Retrieves a fact's value. Returns `nil` if no such fact exists.
    #
    # @param user_query [String] the fact name
    # @return [Hash<String, Object>]
    #
    # @api public
    def to_hash
      log_blocked_facts
      logger.debug("Facter version: #{Facter::VERSION}")

      resolved_facts = Facter::FactManager.instance.resolve_facts
      resolved_facts.reject! { |fact| fact.type == :custom && fact.value.nil? }
      collection = Facter::FactCollection.new.build_fact_collection!(resolved_facts)
      Hash[collection]
    end

    # Check whether printing stack trace is enabled
    #
    # @return [bool]
    #
    # @api public
    def trace?
      Options[:trace]
    end

    # Enable or disable trace
    # @param bool [bool] Set trace on debug state
    #
    # @return [bool] Value of trace debug state
    #
    # @api public
    def trace(bool)
      Options[:trace] = bool
    end

    # Gets the value for a fact. Returns `nil` if no such fact exists.
    #
    # @param user_query [String] the fact name
    # @return [String] the value of the fact, or nil if no fact is found
    #
    # @api public
    def value(user_query)
      user_query = user_query.to_s.downcase
      resolve_fact(user_query) unless @already_searched.include?(user_query)

      @already_searched[user_query]&.value
    end

    # Returns a fact object by name.  If you use this, you still have to
    # call {Facter::Util::Fact#value `value`} on it to retrieve the actual
    # value.
    #
    # @param user_query [String] the name of the fact
    #
    # @return [Facter::Util::Fact, nil] The fact object, or nil if no fact
    #   is found.
    #
    # @api public
    def fact(user_query)
      user_query = user_query.to_s.downcase
      resolve_fact(user_query) unless @already_searched.include?(user_query)

      @already_searched[user_query]
    end

    # Returns Facter version
    #
    # @return [String] Current version
    #
    # @api public
    def version
      Facter::VERSION
    end

    # Gets a hash mapping fact names to their values
    #
    # @return [Array] the hash of fact names and values
    #
    # @api private
    def to_user_output(cli_options, *args)
      init_cli_options(cli_options)
      logger.info("executed with command line: #{ARGV.drop(1).join(' ')}")
      logger.debug("Facter version: #{Facter::VERSION}")
      log_blocked_facts
      resolved_facts = resolve_facts_for_user_query(args)
      fact_formatter = Facter::FormatterFactory.build(Facter::Options.get)
      status = error_check(resolved_facts)

      [fact_formatter.format(resolved_facts), status]
    end

    # Logs an exception and an optional message
    #
    # @return [nil]
    #
    # @api public
    def log_exception(exception, message = nil)
      error_message = []

      error_message << message.to_s unless message.nil? || (message.is_a?(String) && message.empty?)

      parse_exception(exception, error_message)
      logger.error(error_message.flatten.join("\n"))
      nil
    end

    # Returns a list with the names of all resolved facts
    # @return [Array] the list with all the fact names
    #
    # @api public
    def list
      to_hash.keys.sort
    end

    # Logs the message parameter as a warning.
    # @param message [Object] the warning object to be displayed
    #
    # @return [nil]
    #
    # @api public
    def warn(message)
      logger.warn(message.to_s)
      nil
    end

    # Logs only once the same warning message.
    # @param message [Object] the warning message object
    #
    # @return [nil]
    #
    # @api public
    def warnonce(message)
      logger.warnonce(message)
      nil
    end

    private

    def queried_facts(user_query)
      log_blocked_facts
      resolved_facts = Facter::FactManager.instance.resolve_facts(user_query)
      resolved_facts.reject! { |fact| fact.type == :custom && fact.value.nil? }

      if user_query.count.zero?
        Facter::FactCollection.new.build_fact_collection!(resolved_facts)
      else
        FormatterHelper.retrieve_facts_to_display_for_user_query(user_query, resolved_facts)
      end
    end

    def resolve_facts_for_user_query(user_query)
      resolved_facts = Facter::FactManager.instance.resolve_facts(user_query)
      user_querie = resolved_facts.uniq(&:user_query).map(&:user_query).first

      resolved_facts.reject! { |fact| fact.type == :custom && fact.value.nil? } if user_querie&.empty?

      resolved_facts
    end

    def parse_exception(exception, error_message)
      if exception.is_a?(Exception)
        error_message << exception.message if error_message.empty?

        if Options[:trace] && !exception.backtrace.nil?
          error_message << 'backtrace:'
          error_message.concat(exception.backtrace)
        end
      elsif error_message.empty?
        error_message << exception.to_s
      end
    end

    def logger
      @logger ||= Log.new(self)
    end

    def init_cli_options(options)
      options = options.map { |(k, v)| [k.to_sym, v] }.to_h
      Facter::Options.init_from_cli(options)
    end

    def add_fact_to_searched_facts(user_query, value)
      @already_searched[user_query] ||= ResolvedFact.new(user_query, value)
      @already_searched[user_query].value = value
    end

    # Returns a ResolvedFact and saves the result in @already_searched array that is used as a global collection.
    # @param user_query [String] Fact that needs resolution
    #
    # @return [ResolvedFact]
    def resolve_fact(user_query)
      user_query = user_query.to_s
      resolved_facts = Facter::FactManager.instance.resolve_fact(user_query)
      # we must make a distinction between custom facts that return nil and nil facts
      # Nil facts should not be packaged as ResolvedFacts! (add_fact_to_searched_facts packages facts)
      resolved_facts = resolved_facts.reject { |fact| fact.type == :nil }
      fact_collection = FactCollection.new.build_fact_collection!(resolved_facts)

      begin
        value = fact_collection.value(user_query)
        add_fact_to_searched_facts(user_query, value)
      rescue KeyError, TypeError
        nil
      end
    end

    # Returns exit status when user query contains facts that do
    #   not exist
    #
    # @param resolved_facts [Array] List of resolved facts
    #
    # @return [1/nil] Will return status 1 if user query contains
    #  facts that are not found or resolved, otherwise it will return nil
    #
    # @api private
    def error_check(resolved_facts)
      status = 0
      if Options[:strict]
        missing_names = resolved_facts.select { |fact| fact.type == :nil }.map(&:user_query)

        if missing_names.count.positive?
          status = 1
          log_errors(missing_names)
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
      block_list = Options[:block_list]
      return unless block_list.any? && Facter::Options[:block]

      logger.debug("blocking collection of #{block_list.join("\s")} facts")
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
        logger.error("fact \"#{missing_name}\" does not exist.", true)
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
      logger.error(
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

    prepend ApiDebugger if ENV['API_DEBUG']
  end
end
