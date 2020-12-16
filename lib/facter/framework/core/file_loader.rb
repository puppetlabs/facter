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
  files_to_require.each do |file|
    rpath = file[File.dirname(__FILE__).length+1..-1]
    require_relative rpath
  end
end

load_dir(%w[framework core options])
require_relative '../../../facter/framework/core/options'
require_relative '../../../facter/framework/logging/logger_helper'
require_relative '../../../facter/framework/logging/logger'

require_relative '../../../facter/util/file_helper'

require_relative '../../../facter/resolvers/base_resolver'
require_relative '../../../facter/framework/detector/os_hierarchy'
require_relative '../../../facter/framework/detector/os_detector'

require_relative '../../../facter/framework/config/config_reader'
require_relative '../../../facter/framework/config/fact_groups'

load_dir(['config'])

load_dir(['util'])
load_dir(%w[util resolvers])
load_dir(%w[util facts])
load_dir(%w[util resolvers networking])

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
os_hierarchy.each { |operating_system| load_dir(['util', operating_system.downcase, '**']) }
os_hierarchy.each { |operating_system| load_dir(['facts', operating_system.downcase, '**']) }
os_hierarchy.each { |operating_system| load_dir(['resolvers', operating_system.downcase, '**']) }

require_relative '../../../facter/custom_facts/core/legacy_facter'
load_dir(%w[framework utils])

require_relative '../../../facter/framework/core/fact_augmenter'
require_relative '../../../facter/framework/parsers/query_parser'
