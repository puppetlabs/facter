# frozen_string_literal: true

require 'open3'
require 'json'
require 'yaml'
require 'hocon'
require 'hocon/config_value_factory'
require 'singleton'
require 'logger'

@lib_path = File.join(File.dirname(__FILE__), '../../')

def load_dir(*dirs)
  folder_path = File.join(@lib_path, dirs)
  return unless Dir.exist?(folder_path.tr('*', ''))

  files_to_require = Dir.glob(File.join(folder_path, '*.rb')).reject { |file| file =~ %r{/ffi/} }
  files_to_require.each(&method(:require))
end

load_dir(%w[framework core options])
require 'facter/framework/core/options'
require 'facter/framework/logging/logger_helper'
require 'facter/framework/logging/logger'

require 'facter/util/file_helper'

require 'facter/resolvers/base_resolver'
require 'facter/framework/detector/os_hierarchy'
require 'facter/framework/detector/os_detector'

require 'facter/framework/config/config_reader'
require 'facter/framework/config/fact_groups'

load_dir(['config'])

load_dir(%w[resolvers utils])
load_dir(%w[resolvers utils networking])
load_dir(['resolvers'])
load_dir(['facts_utils'])
load_dir(%w[framework core])
load_dir(['models'])
load_dir(%w[framework benchmarking])

load_dir(%w[framework core fact_loaders])
load_dir(%w[framework core fact internal])
load_dir(%w[framework core fact external])
load_dir(%w[framework formatters])

os_hierarchy = OsDetector.instance.hierarchy
os_hierarchy.each { |operating_system| load_dir(['facts', operating_system.downcase, '**']) }
os_hierarchy.each { |operating_system| load_dir(['resolvers', operating_system.downcase, '**']) }

require 'facter/custom_facts/core/legacy_facter'
load_dir(%w[framework utils])
load_dir(['util'])

require 'facter/framework/core/fact_augmenter'
require 'facter/framework/parsers/query_parser'
