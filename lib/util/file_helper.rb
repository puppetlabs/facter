# frozen_string_literal: true

module Facter
  module Util
    class FileHelper
      @log = Log.new(self)

      class << self
        DEBUG_MESSAGE = 'File at: %s is not accessible.'

        def safe_read(path, default_return = '')
          return File.read(path) if File.readable?(path)

          log_failed_to_read(path)
          default_return
        end

        def safe_readlines(path, default_return = [])
          return File.readlines(path) if File.readable?(path)

          log_failed_to_read(path)
          default_return
        end

        private

        def log_failed_to_read(path)
          @log.debug(DEBUG_MESSAGE % path)
        end
      end
    end
  end
end
