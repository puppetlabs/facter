# frozen_string_literal: true

module Facter
  module Util
    class FileHelper
      @log = Log.new(self)

      class << self
        DEBUG_MESSAGE = 'File at: %s is not accessible.'

        def safe_read(path, default_return = '')
          return File.read(path, encoding: Encoding::UTF_8) if File.readable?(path)

          log_failed_to_read(path)
          default_return
        end

        # rubocop:disable Style/SpecialGlobalVars
        def safe_readlines(path, default_return = [], sep = $/, chomp: false)
          return File.readlines(path, sep, chomp: chomp, encoding: Encoding::UTF_8) if File.readable?(path)

          log_failed_to_read(path)
          default_return
        end
        # rubocop:enable Style/SpecialGlobalVars

        # This previously acted as a helper method for versions of Ruby older
        # than 2.5, before Dir.children was added. As it isn't a private
        # method, we can't remove it entirely until the next major Facter
        # release (presumably Facter 5).
        def dir_children(path)
          Dir.children(path)
        end

        private

        def log_failed_to_read(path)
          @log.debug(DEBUG_MESSAGE % path)
        end
      end
    end
  end
end
