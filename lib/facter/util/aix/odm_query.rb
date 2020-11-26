# frozen_string_literal: true

# CuAt (Customized Attributes) non-default attribute values
# CuDv (Customized Devices) the devices present on this machine
# PdAt (Predefined Attributes) default values for all device attributes
# PdDv (Predefined Devices) the list of all devices supported by this release of AIX

module Facter
  module Util
    module Aix
      class ODMQuery
        REPOS = %w[CuAt CuDv PdAt PdDv].freeze

        def initialize
          @query = ''
          @conditions = []
          @log = Facter::Log.new(self)
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

            result = Facter::Core::Execution.execute("#{query} #{repo}", logger: @log)
          end
          result
        end

        def query
          'odmget -q "' + @conditions.join(' AND ') + '"'
        end
      end
    end
  end
end
