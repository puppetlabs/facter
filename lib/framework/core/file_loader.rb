# frozen_string_literal: true

require 'open3'
require 'json'
require 'yaml'
require 'hocon'

def load_dir(*dirs)
  Dir.glob(File.join(ROOT_DIR, dirs, '*.rb'), &method(:require))
end

def load_lib_dirs(*dirs)
  load_dir(['lib', dirs])
end

require "#{ROOT_DIR}/lib/framework/logging/multilogger"
require "#{ROOT_DIR}/lib/framework/logging/logger"
require "#{ROOT_DIR}/lib/resolvers/base_resolver"
require "#{ROOT_DIR}/lib/framework/detector/current_os"

load_lib_dirs('framework', 'core', 'options')
require "#{ROOT_DIR}/lib/framework/config/config_reader"
require "#{ROOT_DIR}/lib/framework/config/block_list"
require "#{ROOT_DIR}/lib/facter-ng"
require "#{ROOT_DIR}/lib/resolvers/utils/fingerprint.rb"
require "#{ROOT_DIR}/lib/resolvers/utils/ssh.rb"

load_dir(['config'])

load_lib_dirs('resolvers')
load_lib_dirs('facts_utils')
load_lib_dirs('utils')
load_lib_dirs('framework', 'core')
load_lib_dirs('models')
load_lib_dirs('framework', 'core', 'fact_loaders')
load_lib_dirs('framework', 'core', 'fact', 'internal')
load_lib_dirs('framework', 'core', 'fact', 'external')

os = ENV['RACK_ENV'] == 'test' ? '' : CurrentOs.instance.identifier

os_hierarchy = CurrentOs.instance.hierarchy
os_hierarchy.each { |operating_system| load_lib_dirs('facts', operating_system.downcase, '**') }

load_lib_dirs('resolvers', os.to_s, '**') if os.to_s =~ /win|aix|solaris/

require "#{ROOT_DIR}/lib/custom_facts/core/legacy_facter"
require "#{ROOT_DIR}/lib/framework/utils/utils"
require "#{ROOT_DIR}/lib/framework/formatters/formatter_factory"
require "#{ROOT_DIR}/lib/framework/formatters/hocon_fact_formatter"
require "#{ROOT_DIR}/lib/framework/formatters/json_fact_formatter"
require "#{ROOT_DIR}/lib/framework/formatters/yaml_fact_formatter"

require "#{ROOT_DIR}/lib/framework/core/fact_augmenter"
require "#{ROOT_DIR}/lib/framework/parsers/query_parser"
