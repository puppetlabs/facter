# frozen_string_literal: true

require 'pathname'

ROOT_DIR      = Pathname.new(File.expand_path('..', __dir__)) unless defined?(ROOT_DIR)
VERSION_FILE  = ROOT_DIR.join('VERSION')
VERSION       = File.read(VERSION_FILE)
