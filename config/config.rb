# frozen_string_literal: true

require 'pathname'
ROOT_DIR = Pathname.new(File.expand_path('..', __dir__)) unless defined?(ROOT_DIR)

FACTER_VERSION = File.read("#{ROOT_DIR}/VERSION").strip
