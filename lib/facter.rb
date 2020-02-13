# frozen_string_literal: true

require 'pathname'

ROOT_DIR = Pathname.new(File.expand_path('..', __dir__)) unless defined?(ROOT_DIR)

require "#{ROOT_DIR}/lib/framework/core/file_loader"
require "#{ROOT_DIR}/lib/framework/core/options/options_validator"

module Facter
  @options = Options.instance

  def self.[](name)
    fact(name)
  end

  def self.add(name, options = {}, &block)
    options[:fact_type] = :custom
    LegacyFacter.add(name, options, &block)
  end

  def self.clear
    LegacyFacter.clear
  end

  def self.core_value(user_query)
    user_query = user_query.to_s
    resolved_facts = Facter::FactManager.instance.resolve_core([user_query])
    fact_collection = FactCollection.new.build_fact_collection!(resolved_facts)
    splitted_user_query = Facter::Utils.split_user_query(user_query)
    fact_collection.dig(*splitted_user_query)
  end

  def self.debug(msg)
    return unless debugging?

    @logger ||= Log.new(self)
    @logger.debug(msg)
    nil
  end

  def self.debugging?
    Options[:debug]
  end

  def self.debugging(debug_bool)
    @options.priority_options = { debug: true }
    @options.refresh

    debug_bool
  end

  def self.fact(name)
    fact = Facter::Util::Fact.new(name)
    val = value(name)
    fact.add({}) { setcode { val } }
    fact
  end

  def self.log_errors(missing_names)
    @logger ||= Log.new(self)

    missing_names.each do |missing_name|
      @logger.error("fact \"#{missing_name}\" does not exist.", true)
    end
  end

  def self.method_missing(name, *args, &block)
    @logger ||= Log.new(self)
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

  def self.reset
    LegacyFacter.reset
  end

  def self.search(*dirs)
    LegacyFacter.search(*dirs)
  end

  def self.search_external(dirs)
    LegacyFacter.search_external(dirs)
  end

  def self.search_external_path
    LegacyFacter.search_external_path
  end

  def self.search_path
    LegacyFacter.search_path
  end

  def self.to_hash
    @options.priority_options = { to_hash: true }
    @options.refresh
    resolved_facts = Facter::FactManager.instance.resolve_facts(@options)
    CacheManager.invalidate_all_caches
    FactCollection.new.build_fact_collection!(resolved_facts)
  end

  def self.to_user_output(cli_options, *args)
    @options.priority_options = cli_options
    @options.refresh(args)

    resolved_facts = Facter::FactManager.instance.resolve_facts(@options, args)
    CacheManager.invalidate_all_caches
    fact_formatter = Facter::FormatterFactory.build(@options)

    status = error_check(args, resolved_facts)

    [fact_formatter.format(resolved_facts), status || 0]
  end

  def self.trace?
    LegacyFacter.trace?
  end

  def self.trace(bool)
    LegacyFacter.trace(bool)
  end

  def self.value(user_query)
    @options.refresh([user_query])
    user_query = user_query.to_s
    resolved_facts = Facter::FactManager.instance.resolve_facts(@options, [user_query])
    CacheManager.invalidate_all_caches
    fact_collection = FactCollection.new.build_fact_collection!(resolved_facts)
    splitted_user_query = Facter::Utils.split_user_query(user_query)
    fact_collection.dig(*splitted_user_query)
  end

  def self.version
    version_file = ::File.join(ROOT_DIR, 'VERSION')
    ::File.read(version_file).strip
  end

  private_class_method def self.error_check(args, resolved_facts)
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
end
