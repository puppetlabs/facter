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
  end
end
