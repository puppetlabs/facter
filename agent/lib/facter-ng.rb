# frozen_string_literal: true

require 'pathname'

ROOT_DIR = Pathname.new(File.expand_path('../../', __dir__)) unless defined?(ROOT_DIR)

require "#{ROOT_DIR}/lib/facter"
