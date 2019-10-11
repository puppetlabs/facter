# frozen_string_literal: true

require "#{ROOT_DIR}/lib/custom_facts/version"
require "#{ROOT_DIR}/lib/custom_facts/core/logging"
require "#{ROOT_DIR}/lib/custom_facts/core/legacy_facter"
require "#{ROOT_DIR}/lib/custom_facts/util/fact"
require "#{ROOT_DIR}/lib/custom_facts/util/collection"
require "#{ROOT_DIR}/lib/custom_facts/util/fact"
require "#{ROOT_DIR}/lib/custom_facts/util/loader"
require "#{ROOT_DIR}/lib/custom_facts/core/execution/base"
require "#{ROOT_DIR}/lib/custom_facts/core/execution/windows"
require "#{ROOT_DIR}/lib/custom_facts/core/execution/posix"
require "#{ROOT_DIR}/lib/custom_facts/util/values"
require "#{ROOT_DIR}/lib/custom_facts/util/confine"

require "#{ROOT_DIR}/lib/custom_facts/util/config"
require "#{ROOT_DIR}/lib/custom_facts/util/windows"
# require "#{ROOT_DIR}/lib/custom_facts/util/windows/api_types"
# require "#{ROOT_DIR}/lib/custom_facts/util/windows/error"
# require "#{ROOT_DIR}/lib/custom_facts/util/windows/user"
# require "#{ROOT_DIR}/lib/custom_facts/util/windows/process"

# if LegacyFacter::Util::Config.windows?
#   require_relative 'windows/api_types'
#   require_relative 'windows/error'
#   require_relative 'windows/user'
#   require_relative 'windows/process'
#
#   require_relative 'windows/dir'
#   require_relative 'windows_root'
# else
#   require_relative 'unix_root'
# end


# require "#{ROOT_DIR}/lib/custom_facts/util/windows/dir"
# require "#{ROOT_DIR}/lib/custom_facts/util/windows_root"

require "#{ROOT_DIR}/lib/custom_facts/util/normalization"
require "#{ROOT_DIR}/lib/custom_facts/core/execution"
require "#{ROOT_DIR}/lib/custom_facts/core/resolvable"
require "#{ROOT_DIR}/lib/custom_facts/core/suitable"
require "#{ROOT_DIR}/lib/custom_facts/util/resolution"
require "#{ROOT_DIR}/lib/custom_facts/core/directed_graph"
require "#{ROOT_DIR}/lib/custom_facts/core/resolvable"
require "#{ROOT_DIR}/lib/custom_facts/core/aggregate"
require "#{ROOT_DIR}/lib/custom_facts/util/composite_loader"
require "#{ROOT_DIR}/lib/custom_facts/util/parser"
require "#{ROOT_DIR}/lib/custom_facts/util/directory_loader"
require "#{ROOT_DIR}/lib/custom_facts/util/nothing_loader"
require "#{ROOT_DIR}/lib/custom_facts/util/nothing_loader"
