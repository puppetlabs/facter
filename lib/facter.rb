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

  class << self
    def [](name)
      fact(name)
    end

    def add(name, options = {}, &block)
      options[:fact_type] = :custom
      LegacyFacter.add(name, options, &block)
    end

    def clear
      LegacyFacter.clear
    end

    def core_value(user_query)
      user_query = user_query.to_s
      resolved_facts = Facter::FactManager.instance.resolve_core([user_query])
      fact_collection = FactCollection.new.build_fact_collection!(resolved_facts)
      splitted_user_query = Facter::Utils.split_user_query(user_query)
      fact_collection.dig(*splitted_user_query)
    end

    def debug(msg)
      return unless debugging?

      @logger.debug(msg)
      nil
    end

    def on_message(&block)
      Facter::Log.on_message(&block)
    end

    def debugging?
      Options[:debug]
    end

    def debugging(debug_bool)
      @options.priority_options[:debug] = debug_bool
      @options.refresh

      debug_bool
    end

    def fact(name)
      fact = Facter::Util::Fact.new(name)
      val = value(name)
      fact.add({}) { setcode { val } }
      fact
    end

    def log_errors(missing_names)
      missing_names.each do |missing_name|
        @logger.error("fact \"#{missing_name}\" does not exist.", true)
      end
    end

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

    def reset
      LegacyFacter.reset
    end

    def search(*dirs)
      LegacyFacter.search(*dirs)
    end

    def search_external(dirs)
      LegacyFacter.search_external(dirs)
    end

    def search_external_path
      LegacyFacter.search_external_path
    end

    def search_path
      LegacyFacter.search_path
    end

    def to_hash
      @options.priority_options[:to_hash] = true
      @options.refresh

      log_blocked_facts

      resolved_facts = Facter::FactManager.instance.resolve_facts
      CacheManager.invalidate_all_caches
      FactCollection.new.build_fact_collection!(resolved_facts)
    end

    def to_user_output(cli_options, *args)
      @options.priority_options = { is_cli: true }.merge!(cli_options.map { |(k, v)| [k.to_sym, v] }.to_h)
      @options.refresh(args)

      log_blocked_facts

      resolved_facts = Facter::FactManager.instance.resolve_facts(args)
      CacheManager.invalidate_all_caches
      fact_formatter = Facter::FormatterFactory.build(@options)

      status = error_check(args, resolved_facts)

      [fact_formatter.format(resolved_facts), status || 0]
    end

    def trace?
      LegacyFacter.trace?
    end

    def trace(bool)
      LegacyFacter.trace(bool)
    end

    def value(user_query)
      @options.refresh([user_query])
      user_query = user_query.to_s
      resolved_facts = Facter::FactManager.instance.resolve_facts([user_query])
      CacheManager.invalidate_all_caches
      fact_collection = FactCollection.new.build_fact_collection!(resolved_facts)
      splitted_user_query = Facter::Utils.split_user_query(user_query)
      fact_collection.dig(*splitted_user_query)
    end

    def version
      version_file = ::File.join(ROOT_DIR, 'VERSION')
      ::File.read(version_file).strip
    end

    private

    def log_blocked_facts
      block_list = BlockList.instance.block_list
      @logger.debug("blocking collection of #{block_list.join("\s")} facts") if block_list.any? && Options[:block]
    end

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
  end
end
