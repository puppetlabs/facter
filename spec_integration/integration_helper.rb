# frozen_string_literal: true

require 'open3'

class IntegrationHelper
  class << self
    def exec_facter(*args)
      cmd = %w[bundle exec facter].concat(args)
      Open3.capture3(*cmd)
    end

    def jruby?
      RUBY_PLATFORM == 'java'
    end

    def create_file(path, content)
      dir = File.dirname(path)
      FileUtils.mkdir_p(dir)
      File.write(path, content)

      File.expand_path(path)
    end
  end
end
