require 'pathname'

VERSION       = "0.0.1"
ROOT_DIR      = Pathname.new(File.expand_path('..', __dir__)) unless defined?(ROOT_DIR)
HELP_FILE     = ROOT_DIR.join('help.txt')

