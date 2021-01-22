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
    f = Pathname.new(file)
    cleaned = f.cleanpath
    short = cleaned.to_s.gsub 'C:/Program Files/Puppet Labs/Bolt', 'C:/PROGRA~1/PUPPET~1/Bolt'

    puts short
    puts Pathname.new(cleaned).relative_path_from(Pathname.new(File.dirname(__FILE__)))

    require_relative short
  end
end

# load_dir(['framework', 'core', 'options'])
require_relative 'options/config_file_options'
require_relative 'options/options_validator'
require_relative 'options/option_store'

require_relative 'options'
require_relative '../logging/logger_helper'
require_relative '../logging/logger'

require_relative '../../util/file_helper'

require_relative '../../resolvers/base_resolver'
require_relative '../detector/os_hierarchy'
require_relative '../detector/os_detector'

require_relative '../config/config_reader'
require_relative '../config/fact_groups'

# load_dir(['config']) # returns nothing

# load_dir(['util'])
require_relative '../../util/api_debugger'
# require_relative '../../util/file_helper' # line 50
require_relative '../../util/utils'

# load_dir(%w[util resolvers])
require_relative '../../util/resolvers/aws_token'
require_relative '../../util/resolvers/filesystem_helper'
require_relative '../../util/resolvers/fingerprint'
require_relative '../../util/resolvers/http'
require_relative '../../util/resolvers/networking'
require_relative '../../util/resolvers/ssh'
require_relative '../../util/resolvers/ssh_helper'
require_relative '../../util/resolvers/uptime_helper'

# load_dir(%w[util facts])
require_relative '../../util/facts/facts_utils'
require_relative '../../util/facts/unit_converter'
require_relative '../../util/facts/uptime_parser'
require_relative '../../util/facts/virtual_detector'
require_relative '../../util/facts/windows_release_finder'

# load_dir(%w[util resolvers networking])
require_relative '../../util/resolvers/networking/dhcp'
require_relative '../../util/resolvers/networking/networking'
require_relative '../../util/resolvers/networking/primary_interface'

# load_dir(['resolvers'])
require_relative '../../resolvers/aio_agent_version'
require_relative '../../resolvers/augeas'
# require_relative '../../resolvers/base_resolver' # line 37
require_relative '../../resolvers/cloud'
require_relative '../../resolvers/containers'
require_relative '../../resolvers/debian_version'
require_relative '../../resolvers/disk'
require_relative '../../resolvers/dmi'
require_relative '../../resolvers/dmi_decode'
require_relative '../../resolvers/ec2'
require_relative '../../resolvers/eos_release'
require_relative '../../resolvers/facterversion'
require_relative '../../resolvers/filesystems'
require_relative '../../resolvers/fips_enabled'
require_relative '../../resolvers/gce'
require_relative '../../resolvers/hostname'
require_relative '../../resolvers/identity'
require_relative '../../resolvers/load_averages'
require_relative '../../resolvers/lpar'
require_relative '../../resolvers/lsb_release'
require_relative '../../resolvers/lspci'
require_relative '../../resolvers/memory'
require_relative '../../resolvers/mountpoints'
require_relative '../../resolvers/networking'
require_relative '../../resolvers/networking_linux'
require_relative '../../resolvers/open_vz'
require_relative '../../resolvers/os_release'
require_relative '../../resolvers/partitions'
require_relative '../../resolvers/path'
require_relative '../../resolvers/processors'
require_relative '../../resolvers/redhat_release'
require_relative '../../resolvers/ruby'
require_relative '../../resolvers/selinux'
require_relative '../../resolvers/ssh'
require_relative '../../resolvers/suse_release'
require_relative '../../resolvers/sw_vers'
require_relative '../../resolvers/timezone'
require_relative '../../resolvers/uname'
require_relative '../../resolvers/uptime'
require_relative '../../resolvers/virt_what'
require_relative '../../resolvers/vmware'
require_relative '../../resolvers/wpar'
require_relative '../../resolvers/xen'
require_relative '../../resolvers/zfs'
require_relative '../../resolvers/zpool'

# load_dir(['facts_utils'])
# load_dir(%w[framework core])
require_relative 'cache_manager'
require_relative 'fact_augmenter'
require_relative 'fact_filter'
require_relative 'fact_manager'
# require_relative 'file_loader' # load ourselves?
require_relative 'options'
require_relative 'session_cache'

# load_dir(['models'])
require_relative '../../models/fact_collection'
require_relative '../../models/loaded_fact'
require_relative '../../models/resolved_fact'
require_relative '../../models/searched_fact'

# load_dir(%w[framework benchmarking])
require_relative '../benchmarking/timer'

# load_dir(%w[framework core fact_loaders])
require_relative 'fact_loaders/class_discoverer'
require_relative 'fact_loaders/external_fact_loader'
require_relative 'fact_loaders/fact_loader'
require_relative 'fact_loaders/internal_fact_loader'

# load_dir(%w[framework core fact internal])
require_relative 'fact/internal/core_fact'
require_relative 'fact/internal/internal_fact_manager'

# load_dir(%w[framework core fact external])
require_relative 'fact/external/external_fact_manager'

# load_dir(%w[framework formatters])
require_relative '../formatters/formatter_factory'
require_relative '../formatters/formatter_helper'
require_relative '../formatters/hocon_fact_formatter'
require_relative '../formatters/json_fact_formatter'
require_relative '../formatters/legacy_fact_formatter'
require_relative '../formatters/yaml_fact_formatter'

os_hierarchy = OsDetector.instance.hierarchy
os_hierarchy.each { |operating_system| load_dir(['util', operating_system.downcase, '**']) }
os_hierarchy.each { |operating_system| load_dir(['facts', operating_system.downcase, '**']) }
os_hierarchy.each { |operating_system| load_dir(['resolvers', operating_system.downcase, '**']) }

require_relative '../../custom_facts/core/legacy_facter'
# load_dir(%w[framework utils])  # no such dir, returns nothing

require_relative '../core/fact_augmenter'
require_relative '../parsers/query_parser'