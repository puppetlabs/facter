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

require_relative '../../framework/core/options/config_file_options'
require_relative '../../framework/core/options/option_store'
require_relative '../../framework/core/options/options_validator'

require_relative '../../../facter/framework/core/options'
require_relative '../../../facter/framework/logging/logger_helper'
require_relative '../../../facter/framework/logging/logger'

require_relative '../../../facter/util/file_helper'

require_relative '../../../facter/resolvers/base_resolver'
require_relative '../../../facter/framework/detector/os_hierarchy'
require_relative '../../../facter/framework/detector/os_detector'

require_relative '../../../facter/framework/config/config_reader'
require_relative '../../../facter/framework/config/fact_groups'

require_relative '../../util/api_debugger'
require_relative '../../util/file_helper'
require_relative '../../util/utils'

require_relative '../../util/resolvers/aws_token'
require_relative '../../util/resolvers/filesystem_helper'
require_relative '../../util/resolvers/fingerprint'
require_relative '../../util/resolvers/http'
require_relative '../../util/resolvers/ssh'
require_relative '../../util/resolvers/ssh_helper'
require_relative '../../util/resolvers/uptime_helper'

require_relative '../../util/facts/facts_utils'
require_relative '../../util/facts/unit_converter'
require_relative '../../util/facts/uptime_parser'
require_relative '../../util/facts/windows_release_finder'

require_relative '../../util/facts/posix/virtual_detector'

require_relative '../../util/resolvers/networking/dhcp'
require_relative '../../util/resolvers/networking/networking'
require_relative '../../util/resolvers/networking/primary_interface'

require_relative '../../resolvers/aio_agent_version'
require_relative '../../resolvers/augeas'
require_relative '../../resolvers/az'
require_relative '../../resolvers/base_resolver'
require_relative '../../resolvers/containers'
require_relative '../../resolvers/debian_version'
require_relative '../../resolvers/disks'
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
require_relative '../../resolvers/open_vz'
require_relative '../../resolvers/os_release'
require_relative '../../resolvers/partitions'
require_relative '../../resolvers/path'
require_relative '../../resolvers/processors'
require_relative '../../resolvers/processors_lscpu'
require_relative '../../resolvers/redhat_release'
require_relative '../../resolvers/release_from_first_line'
require_relative '../../resolvers/ruby'
require_relative '../../resolvers/selinux'
require_relative '../../resolvers/specific_release_file'
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

require_relative '../../framework/core/cache_manager'
require_relative '../../framework/core/fact_filter'
require_relative '../../framework/core/fact_manager'
require_relative '../../framework/core/options'
require_relative '../../framework/core/session_cache'

require_relative '../../models/fact_collection'
require_relative '../../models/loaded_fact'
require_relative '../../models/resolved_fact'
require_relative '../../models/searched_fact'

require_relative '../../framework/benchmarking/timer'

require_relative '../../framework/core/fact_loaders/class_discoverer'
require_relative '../../framework/core/fact_loaders/external_fact_loader'
require_relative '../../framework/core/fact_loaders/fact_loader'
require_relative '../../framework/core/fact_loaders/internal_fact_loader'

require_relative '../../framework/core/fact/internal/core_fact'
require_relative '../../framework/core/fact/internal/internal_fact_manager'

require_relative '../../framework/core/fact/external/external_fact_manager'

require_relative '../../framework/formatters/formatter_factory'
require_relative '../../framework/formatters/formatter_helper'
require_relative '../../framework/formatters/hocon_fact_formatter'
require_relative '../../framework/formatters/json_fact_formatter'
require_relative '../../framework/formatters/legacy_fact_formatter'
require_relative '../../framework/formatters/yaml_fact_formatter'

os_hierarchy = OsDetector.instance.hierarchy
os_hierarchy.each { |operating_system| load_dir(['util', operating_system.downcase, '**']) }
os_hierarchy.each { |operating_system| load_dir(['facts', operating_system.downcase, '**']) }
os_hierarchy.each { |operating_system| load_dir(['resolvers', operating_system.downcase, '**']) }

require_relative '../../../facter/custom_facts/core/legacy_facter'

require_relative '../../../facter/framework/parsers/query_parser'
