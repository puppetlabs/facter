# frozen_string_literal: true

# CuAt (Customized Attributes) non-default attribute values
# CuDv (Customized Devices) the devices present on this machine
# PdAt (Predefined Attributes) default values for all device attributes
# PdDv (Predefined Devices) the list of all devices supported by this release of AIX

module Facter
  class ODMQuery
    REPOS = %w[CuAt CuDv PdAt PdDv].freeze

    def initialize
      @query = ''
      @conditions = []
    end

    def equals(field, value)
      @conditions << "#{field}='#{value}'"
      self
    end

    def like(field, value)
      @conditions << "#{field} like '#{value}'"
      self
    end

    def execute
      result = nil
      REPOS.each do |repo|
        break if result && !result.empty?

        result, _stderr, _s = Open3.capture3("#{query} #{repo}")
      end
      result
    end

    def query
      'odmget -q "' + @conditions.join(' AND ') + '"'
    end
  end
end
