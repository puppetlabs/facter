# frozen_string_literal: true

require 'open3'
require 'json'

require "#{ROOT_DIR}/lib/resolvers/base_resolver"
require "#{ROOT_DIR}/lib/facter"

def load_dir(*dirs)
  Dir.glob(File.join(ROOT_DIR, dirs, '*.rb'), &method(:require))
end
load_dir(['config'])
# load_dir(['lib'])

def load_lib_dirs(*dirs)
  load_dir(['lib', dirs])
end

load_lib_dirs('resolvers')
load_lib_dirs('utils')
load_lib_dirs('models')

os = OsDetector.detect_family

load_lib_dirs('facts', os.to_s, '**')
