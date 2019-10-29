# frozen_string_literal: true

require 'pathname'

ROOT_DIR = Pathname.new(File.expand_path('..', __dir__)) unless defined?(ROOT_DIR)
require "#{ROOT_DIR}/lib/framework/core/file_loader"

module Facter
  def self.to_hash
    resolved_facts = Facter::FactManager.instance.resolve_facts
    CacheManager.invalidate_all_caches
    FactCollection.new.build_fact_collection!(resolved_facts)
  end

  def self.to_user_output(options, *args)
    resolved_facts = Facter::FactManager.instance.resolve_facts(options, args)
    CacheManager.invalidate_all_caches
    fact_formatter = Facter::FormatterFactory.build(options)
    fact_formatter.format(resolved_facts)
  end

  def self.value(user_query)
    resolved_facts = Facter::FactManager.instance.resolve_facts({}, [user_query])
    CacheManager.invalidate_all_caches
    fact_collection = FactCollection.new.build_fact_collection!(resolved_facts)
    fact_collection.dig(*user_query.split('.'))
  end

  def self.add(name, options = {}, &block)
    LegacyFacter.add(name, options, &block)
  end

  def self.core_value(user_query)
    user_query = user_query.to_s
    resolved_facts = Facter::FactManager.instance.resolve_core({}, [user_query])
    fact_collection = FactCollection.new.build_fact_collection!(resolved_facts)
    fact_collection.dig(*user_query.split('.'))
  end

  def self.method_missing(name, *args, &block)
    log = Facter::Log.new
    log.debug(
      "--#{name}-- not implemented but required" \
      'with params:' \
      "#{args.inspect}" \
      'with block:' \
      "#{block.inspect}" \
      'called by:' \
      "#{caller}"
    )
  end
end
